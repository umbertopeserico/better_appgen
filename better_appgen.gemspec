# frozen_string_literal: true

require_relative "lib/better_appgen/version"

Gem::Specification.new do |spec|
  spec.name = "better_appgen"
  spec.version = BetterAppgen::VERSION
  spec.authors = ["Pandev"]
  spec.email = ["info@pandev.it"]

  spec.summary = "Rails 8 app generator with Solid Stack, Vite, Tailwind, and Docker"
  spec.description = <<~DESC.gsub("\n", " ").strip
    BetterAppgen generates production-ready Rails 8 applications with a modern, opinionated stack.
    Features include: Solid Stack (Cache, Queue, Cable) backed by PostgreSQL instead of Redis,
    Vite 7 with Tailwind CSS 4 and Stimulus for frontend, multi-database architecture with
    separate databases for app, cache, queue, and cable, UUID primary keys by default,
    complete Docker development environment with helper scripts, configurable locale support
    (en, it, de, fr, es, pt, nl, pl, ru, ja, zh), and optional SimpleForm integration with
    Tailwind styling. Get a fully configured Rails 8 app in seconds.
  DESC
  spec.homepage = "https://github.com/pandev-srl/better_appgen"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = spec.homepage
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.post_install_message = <<~MSG
    Thanks for installing BetterAppgen!

    Quick start:
      better_appgen new my-app

    For more options:
      better_appgen help new

    Check dependencies:
      better_appgen check
  MSG

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end + Dir["lib/better_appgen/templates/**/*"]

  spec.bindir = "exe"
  spec.executables = ["better_appgen"]
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "pastel", "~> 0.8"
  spec.add_dependency "thor", "~> 1.3"
  spec.add_dependency "tty-spinner", "~> 0.9"
end
