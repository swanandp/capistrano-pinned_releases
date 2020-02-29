# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "capistrano/pinned_releases/version"

Gem::Specification.new do |spec|
  spec.name = "capistrano-pinned_releases"
  spec.version = Capistrano::PinnedReleases::VERSION
  spec.authors = ["Swanand Pagnis"]
  spec.email = ["swanand.pagnis@gmail.com"]
  spec.summary = "Capistrano extension to pin and unpin releases. Pinned releases don't get deleted during cleanup"
  spec.homepage = "https://github.com/swanandp/capistrano-pinned_releases"
  spec.required_ruby_version = ">= 2.3.1"

  spec.description = <<~TEXT
    Capistrano extension to pin and unpin releases. Pinned releases don't get deleted during `deploy:cleanup`.
    Unpin the release to unprotect it.
  TEXT

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.

  raise "RubyGems 2.0 or newer is required to protect against public gem pushes." unless spec.respond_to?(:metadata)

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/swanandp/capistrano-pinned_releases"
  spec.metadata["changelog_uri"] = "https://github.com/swanandp/capistrano-pinned_releases/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "capistrano", "~> 3.4"
  spec.add_dependency "capistrano-bundler", "~> 1.1"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 13.0"
end
