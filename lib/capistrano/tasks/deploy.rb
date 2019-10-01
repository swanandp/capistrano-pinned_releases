# frozen_string_literal: true

namespace :deploy do
  namespace :check do
    desc "Check shared and release directories exist"
    task :directories do
      on release_roles :all do
        execute :mkdir, "-p", deploy_path.join("pinned_releases")
      end
    end
  end

  namespace :pinned do
    # rubocop:disable Metrics/LineLength
    desc "Pin a given release: 'cap production deploy:pin:release RELEASE_NAME=20190220192205', without RELEASE_NAME pins the current release"
    # rubocop:enable Metrics/LineLength
    task pin: "deploy:check" do
      on release_roles :all do
        release_name = ENV.fetch("RELEASE_NAME", "current")
        releases_directory = deploy_path.join("releases")
        pinned_releases_directory = deploy_path.join("pinned_releases")

        if release_name == "current"
          current_release_path = capture(:readlink, release_path.parent.join(current_path.basename))
          current_release_name = capture(:basename, current_release_path)

          pin_target = current_release_path
          pin_name = pinned_releases_directory.join(current_release_name)
        else
          pin_target = releases_directory.join(release_name)
          pin_name = pinned_releases_directory.join(release_name)
        end

        execute(:ln, "-s", pin_target, pin_name) unless test("[ -d #{pin_name} ]")
      end
    end

    # rubocop:disable Metrics/LineLength
    desc "Unpin a given release: 'cap production deploy:pin:remove RELEASE_NAME=20190220192205', without RELEASE_NAME unpins the current release"
    # rubocop:enable Metrics/LineLength
    task unpin: "deploy:check" do
      on release_roles :all do
        release_name = ENV.fetch("RELEASE_NAME", "current")
        pinned_releases_directory = deploy_path.join("pinned_releases")

        if release_name == "current"
          current_release_path = capture(:readlink, release_path.parent.join(current_path.basename))
          current_release_name = capture(:basename, current_release_path)

          pin_name = pinned_releases_directory.join(current_release_name)
        else
          pin_name = pinned_releases_directory.join(release_name)
        end

        execute :rm, "-f", pin_name
      end
    end

    task unpin_old: "deploy:check" do
      on release_roles :all do
        pinned_releases_directory = deploy_path.join("pinned_releases")
        pinned_releases = capture(:ls, pinned_releases_directory).split(/\s+/).sort

        keep_releases = fetch(:keep_releases)

        if pinned_releases.count > keep_releases
          take_count = pinned_releases.count - keep_releases
          releases_to_unpin = pinned_releases.take(take_count)

          releases_to_unpin.each do |pin_name|
            info t(:unpinning_releases, host: host.to_s, release_name: pin_name)
            execute :rm, "-f", pin_name
          end
        end
      end
    end

    desc "List all currently pinned releases"
    task list: "deploy:check" do
      on release_roles :all do
        pinned_releases_directory = deploy_path.join("pinned_releases")
        pinned_releases = capture :ls, pinned_releases_directory
        puts pinned_releases.split(/\s+/).sort.join(", ")
      end
    end
  end

  desc "Clean up old releases"
  Rake::Task["deploy:cleanup"].clear_actions
  task cleanup: "check:directories" do
    on release_roles :all do |host|
      releases = capture(:ls, "-x", releases_path).split
      valid, invalid = releases.partition { |e| /^\d{14}$/ =~ e }

      warn t(:skip_cleanup, host: host.to_s) if invalid.any?

      if valid.count >= fetch(:keep_releases)
        info t(:keeping_releases, host: host.to_s, keep_releases: fetch(:keep_releases), releases: valid.count)
        directories =
          (valid - valid.last(fetch(:keep_releases))).map do |release|
            releases_path.join(release).to_s
          end.reject do |release|
            release_name = capture(:basename, release)

            if test("[ -d #{deploy_path.join('pinned_releases').join(release_name)} ]")
              warn t(:wont_delete_pinned_release, host: host.to_s, release: release_name)
              true
            else
              false
            end
          end

        if test("[ -d #{current_path} ]")
          current_release = capture(:readlink, current_path).to_s

          if directories.include?(current_release)
            warn t(:wont_delete_current_release, host: host.to_s)
            directories.delete(current_release)
          end
        else
          debug t(:no_current_release, host: host.to_s)
        end

        if directories.any?
          execute :rm, "-rf", *directories
        else
          info t(:no_old_releases, host: host.to_s, keep_releases: fetch(:keep_releases))
        end
      end
    end
  end
end
