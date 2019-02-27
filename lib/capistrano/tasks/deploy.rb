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
end
