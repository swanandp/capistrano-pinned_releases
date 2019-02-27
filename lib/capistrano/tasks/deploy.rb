# frozen_string_literal: true

namespace :deploy do
  namespace :check do
    desc "Check shared and release directories exist"
    task :directories do
      on release_roles :all do
        execute :mkdir, "-p", deploy_path.join(fetch(:releases_directory, "pinned_releases"))
      end
    end
  end

  namespace :pin do
    desc "Create a pinned release: Symlink current release to pinned_releases"
    task current: "deploy:check" do
      on release_roles :all do
        real_release_path = capture :readlink, release_path.parent.join(current_path.basename)
        release_name = capture :basename, real_release_path
        pinned_releases_directory = deploy_path.join(fetch(:releases_directory, "pinned_releases"))

        execute :ln, "-s", real_release_path, pinned_releases_directory.join(release_name)
      end
    end

    desc "List all currently pinned releases"
    task list: "deploy:check" do
      on release_roles :all do
        pinned_releases_directory = deploy_path.join(fetch(:releases_directory, "pinned_releases"))
        pinned_releases = capture :ls, pinned_releases_directory
        puts pinned_releases.split(/\s+/).sort.join(", ")
      end
    end
  end

  desc "Clean up old releases"
  Rake::Task["deploy:cleanup"].clear_actions
  task :cleanup do
    on release_roles :all do |host|
      releases = capture(:ls, "-x", releases_path).split
      valid, invalid = releases.partition { |e| /^\d{14}$/ =~ e }

      warn t(:skip_cleanup, host: host.to_s) if invalid.any?

      if valid.count >= fetch(:keep_releases)
        info t(:keeping_releases, host: host.to_s, keep_releases: fetch(:keep_releases), releases: valid.count)
        directories = (valid - valid.last(fetch(:keep_releases))).map do |release|
          releases_path.join(release).to_s
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
