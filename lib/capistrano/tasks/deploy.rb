# frozen_string_literal: true

namespace :deploy do
  desc "Check directories of files to be linked exist in shared"
  task :make_linked_dirs do
    next unless any? :linked_files

    on release_roles :all do |_host|
      execute :mkdir, "-p", deploy_path.join(fetch(:releases_directory, "pinned_releases"))
    end
  end
end
