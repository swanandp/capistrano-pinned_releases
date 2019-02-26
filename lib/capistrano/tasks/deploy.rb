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
end
