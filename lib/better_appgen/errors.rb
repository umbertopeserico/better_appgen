# frozen_string_literal: true

module BetterAppgen
  # Base error class for all BetterAppgen errors
  class Error < StandardError; end

  # Raised when a required dependency is missing
  class DependencyError < Error
    attr_reader :missing_dependencies

    def initialize(missing_dependencies)
      @missing_dependencies = missing_dependencies
      super("Missing required dependencies: #{missing_dependencies.join(", ")}")
    end
  end

  # Raised when the app name is invalid
  class InvalidAppNameError < Error
    def initialize(app_name)
      super("Invalid app name '#{app_name}'. App name must start with a letter and contain only letters, " \
            "numbers, hyphens, and underscores.")
    end
  end

  # Raised when the target directory already exists
  class DirectoryExistsError < Error
    def initialize(path)
      super("Directory '#{path}' already exists. Please choose a different name or remove the existing directory.")
    end
  end

  # Raised when a template file is not found
  class TemplateNotFoundError < Error
    def initialize(template_path)
      super("Template file not found: #{template_path}")
    end
  end

  # Raised when a shell command fails
  class CommandFailedError < Error
    attr_reader :command, :exit_code

    def initialize(command, exit_code)
      @command = command
      @exit_code = exit_code
      super("Command '#{command}' failed with exit code #{exit_code}")
    end
  end

  # Raised when Rails app generation fails
  class RailsGenerationError < Error
    def initialize(message = "Failed to generate Rails application")
      super
    end
  end
end
