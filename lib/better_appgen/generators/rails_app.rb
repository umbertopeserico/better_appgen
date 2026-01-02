# frozen_string_literal: true

module BetterAppgen
  module Generators
    # Creates the base Rails application with optimized skip flags
    class RailsApp < Base
      SKIP_FLAGS = %w[
        --skip-git
        --skip-docker
        --skip-action-mailbox
        --skip-action-text
        --skip-active-storage
        --skip-test
        --skip-thruster
        --skip-ci
        --skip-kamal
        --skip-devcontainer
        --skip-jbuilder
        --skip-javascript
        --skip-asset-pipeline
        --database=postgresql
      ].freeze

      def generate!
        create_rails_app
        cleanup_schema_files
        setup_migration_directories
      end

      private

      def create_rails_app
        command = "rails new #{app_name} #{SKIP_FLAGS.join(" ")}"
        Dir.chdir(File.dirname(app_path)) do
          # Run rails command outside of bundler environment
          Bundler.with_unbundled_env do
            success = system(command)
            raise RailsGenerationError unless success
          end
        end
      end

      def cleanup_schema_files
        # Remove schema.rb files (we use structure.sql instead)
        schema_files = Dir.glob(File.join(app_path, "db", "*schema.rb"))
        schema_files << File.join(app_path, "db", "schema.rb")

        schema_files.each do |file|
          FileUtils.rm_f(file)
        end
      end

      def setup_migration_directories
        create_directory("db/migrate")
        create_directory("db/cache_migrate")
        create_directory("db/queue_migrate")
        create_directory("db/cable_migrate")
      end
    end
  end
end
