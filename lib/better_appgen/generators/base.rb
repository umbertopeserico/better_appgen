# frozen_string_literal: true

require "English"
require "erb"
require "fileutils"
require "json"

module BetterAppgen
  module Generators
    # Base class for all generators with ERB template support
    class Base
      attr_reader :config

      def initialize(config)
        @config = config
      end

      # Main entry point for the generator - subclasses must implement
      def generate!
        raise NotImplementedError, "Subclasses must implement #generate!"
      end

      protected

      # Delegate config accessors
      def app_name = config.app_name
      def app_name_snake = config.app_name_snake
      def app_name_pascal = config.app_name_pascal
      def app_name_dash = config.app_name_dash
      def rails_port = config.rails_port
      def vite_port = config.vite_port
      def locale = config.locale
      def timezone = config.timezone
      def with_simple_form = config.with_simple_form
      def skip_docker = config.skip_docker
      def app_path = config.app_path

      # Returns the templates directory path
      def templates_path
        BetterAppgen.templates_path
      end

      # Reads and renders an ERB template file
      def render_template(template_name, trim_mode: "-")
        template_file = templates_path.join(template_name)
        raise TemplateNotFoundError, template_file unless template_file.exist?

        template_content = template_file.read
        ERB.new(template_content, trim_mode: trim_mode).result(binding)
      end

      # Creates a file with the given content
      def create_file(relative_path, content)
        full_path = File.join(app_path, relative_path)
        FileUtils.mkdir_p(File.dirname(full_path))
        File.write(full_path, content)
      end

      # Creates a file from an ERB template
      def create_file_from_template(relative_path, template_name)
        content = render_template(template_name)
        create_file(relative_path, content)
      end

      # Reads a file from the app directory
      def read_file(relative_path)
        full_path = File.join(app_path, relative_path)
        File.read(full_path)
      end

      # Updates a file with new content
      def update_file(relative_path, content)
        full_path = File.join(app_path, relative_path)
        File.write(full_path, content)
      end

      # Checks if a file exists in the app directory
      def file_exists?(relative_path)
        full_path = File.join(app_path, relative_path)
        File.exist?(full_path)
      end

      # Appends content to a file if not already present
      def append_to_file(relative_path, content)
        full_path = File.join(app_path, relative_path)
        current_content = File.read(full_path)
        return if current_content.include?(content)

        File.write(full_path, current_content + content)
      end

      # Inserts content before a matching pattern
      def insert_before(relative_path, pattern, content)
        full_path = File.join(app_path, relative_path)
        current_content = File.read(full_path)
        new_content = current_content.gsub(pattern) { |match| content + match }
        File.write(full_path, new_content)
      end

      # Inserts content after a matching pattern
      def insert_after(relative_path, pattern, content)
        full_path = File.join(app_path, relative_path)
        current_content = File.read(full_path)
        new_content = current_content.gsub(pattern) { |match| match + content }
        File.write(full_path, new_content)
      end

      # Replaces content matching a pattern
      def gsub_file(relative_path, pattern, replacement)
        full_path = File.join(app_path, relative_path)
        current_content = File.read(full_path)
        new_content = current_content.gsub(pattern, replacement)
        File.write(full_path, new_content)
      end

      # Intelligent Gemfile merge - adds gems without duplicates
      def merge_gemfile(gems_to_add)
        gemfile_path = File.join(app_path, "Gemfile")
        current_content = File.read(gemfile_path)

        gems_to_add.each do |gem_line|
          # Extract gem name from line (e.g., gem "solid_cache" -> solid_cache)
          gem_name = gem_line.match(/gem ["']([^"']+)["']/)[1]

          # Skip if gem already present
          next if current_content.match?(/gem ["']#{Regexp.escape(gem_name)}["']/)

          # Insert before development group if exists, otherwise append
          if current_content.match?(/group :development do/)
            insert_before("Gemfile", /group :development do/, "#{gem_line}\n")
          else
            append_to_file("Gemfile", "\n#{gem_line}\n")
          end
          current_content = File.read(gemfile_path)
        end
      end

      # Intelligent package.json merge
      def merge_package_json(dependencies: {}, dev_dependencies: {}, scripts: {}, extra: {})
        package_path = File.join(app_path, "package.json")

        package_data = if File.exist?(package_path)
                         JSON.parse(File.read(package_path))
                       else
                         { "name" => app_name_dash, "private" => true }
                       end

        # Merge dependencies
        package_data["dependencies"] ||= {}
        package_data["dependencies"].merge!(dependencies)

        # Merge devDependencies
        package_data["devDependencies"] ||= {}
        package_data["devDependencies"].merge!(dev_dependencies)

        # Merge scripts
        package_data["scripts"] ||= {}
        package_data["scripts"].merge!(scripts)

        # Merge extra fields
        extra.each { |key, value| package_data[key] = value }

        # Write formatted JSON
        File.write(package_path, JSON.pretty_generate(package_data))
      end

      # Creates a directory
      def create_directory(relative_path)
        full_path = File.join(app_path, relative_path)
        FileUtils.mkdir_p(full_path)
      end

      # Copies a file within the app directory
      def copy_file(source_path, destination_path)
        source_full = File.join(app_path, source_path)
        dest_full = File.join(app_path, destination_path)
        FileUtils.mkdir_p(File.dirname(dest_full))
        FileUtils.cp(source_full, dest_full)
      end

      # Makes a file executable
      def chmod_executable(relative_path)
        full_path = File.join(app_path, relative_path)
        FileUtils.chmod("+x", full_path)
      end

      # Removes a file or directory
      def remove_file(relative_path)
        full_path = File.join(app_path, relative_path)
        FileUtils.rm_rf(full_path)
      end

      # Generates a timestamp for migrations
      def migration_timestamp(offset_seconds = 0)
        (Time.now + offset_seconds).utc.strftime("%Y%m%d%H%M%S")
      end

      # Runs a shell command in the app directory
      def run_command(command, capture: false)
        Dir.chdir(app_path) do
          if capture
            `#{command}`
          else
            system(command)
          end
        end
      end

      # Runs a shell command and raises on failure
      def run_command!(command)
        Dir.chdir(app_path) do
          success = system(command)
          raise CommandFailedError.new(command, $CHILD_STATUS.exitstatus) unless success
        end
      end
    end
  end
end
