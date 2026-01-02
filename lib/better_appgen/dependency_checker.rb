# frozen_string_literal: true

require "English"
module BetterAppgen
  # Checks for required system dependencies
  class DependencyChecker
    REQUIRED_DEPENDENCIES = {
      "ruby" => { command: "ruby --version", min_version: "3.2.0" },
      "rails" => { command: "rails --version", min_version: "8.0.0" },
      "node" => { command: "node --version", min_version: "20.0.0" },
      "yarn" => { command: "yarn --version", min_version: "4.0.0" },
      "git" => { command: "git --version", min_version: nil },
      "psql" => { command: "psql --version", min_version: nil }
    }.freeze

    attr_reader :pastel

    def initialize
      @pastel = Pastel.new
      @results = {}
    end

    # Check all dependencies, optionally with verbose output
    # Returns true if all dependencies are met
    def check_all(verbose: false)
      missing = []

      REQUIRED_DEPENDENCIES.each do |name, config|
        result = check_dependency(name, config)
        @results[name] = result

        print_result(name, result) if verbose
        missing << name unless result[:satisfied]
      end

      if verbose
        puts
        if missing.empty?
          puts pastel.green("All dependencies satisfied!")
        else
          puts pastel.red("Missing dependencies: #{missing.join(", ")}")
        end
      end

      missing.empty?
    end

    # Check a specific dependency
    def check(name)
      config = REQUIRED_DEPENDENCIES[name.to_s]
      raise Error, "Unknown dependency: #{name}" unless config

      check_dependency(name.to_s, config)[:satisfied]
    end

    # Returns missing dependencies as an array
    def missing_dependencies
      @results.reject { |_, r| r[:satisfied] }.keys
    end

    private

    def check_dependency(_name, config)
      # Run command outside of bundler environment to detect system-wide installations
      output = nil
      installed = false

      Bundler.with_unbundled_env do
        output = `#{config[:command]} 2>&1`.strip
        installed = $CHILD_STATUS.success?
      end

      if installed && config[:min_version]
        version = extract_version(output)
        version_ok = version_satisfied?(version, config[:min_version])
        {
          satisfied: version_ok,
          installed: true,
          version: version,
          min_version: config[:min_version]
        }
      else
        {
          satisfied: installed,
          installed: installed,
          version: installed ? extract_version(output) : nil,
          min_version: config[:min_version]
        }
      end
    end

    def extract_version(output)
      # Match common version patterns like "1.2.3", "v1.2.3", "Ruby 3.2.0", etc.
      match = output.match(/v?(\d+\.\d+(?:\.\d+)?)/i)
      match ? match[1] : nil
    end

    def version_satisfied?(current, required)
      return true unless required && current

      current_parts = current.split(".").map(&:to_i)
      required_parts = required.split(".").map(&:to_i)

      # Compare each version part
      required_parts.each_with_index do |req_part, i|
        cur_part = current_parts[i] || 0
        return true if cur_part > req_part
        return false if cur_part < req_part
      end

      true
    end

    def print_result(name, result)
      if result[:satisfied]
        status = pastel.green("OK")
        version_info = result[:version] ? " (#{result[:version]})" : ""
        puts "  #{status} #{name}#{version_info}"
      else
        status = pastel.red("MISSING")
        if result[:installed] && result[:min_version]
          puts "  #{status} #{name} - version #{result[:version]} < #{result[:min_version]} required"
        else
          puts "  #{status} #{name}"
        end
      end
    end
  end
end
