# frozen_string_literal: true

require "thor"
require "pastel"
require "tty-spinner"

module BetterAppgen
  # CLI class for handling command-line interactions
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc "new APP_NAME", "Generate a new Rails 8 application with an opinionated stack"
    long_desc <<~LONGDESC
      Creates a new Rails 8 application with a production-ready stack including:

      - Solid Cache/Queue/Cable (PostgreSQL-backed instead of Redis)
      - Vite 7 + Tailwind CSS 4 for assets
      - Multi-database setup (primary, cache, queue, cable)
      - Docker development environment (optional)
      - UUID primary keys by default
      - Configurable locale and timezone

      Examples:
        better_appgen new my-blog
        better_appgen new my-app --with-simple-form
        better_appgen new my-app --rails-port 3001 --vite-port 5174
        better_appgen new my-app --skip-docker
        better_appgen new my-app --locale it
    LONGDESC
    method_option :with_simple_form, type: :boolean, default: false,
                                     desc: "Include SimpleForm with Tailwind CSS styling"
    method_option :rails_port, type: :numeric, default: 3000,
                               desc: "Rails server port (default: 3000)"
    method_option :vite_port, type: :numeric, default: 5173,
                              desc: "Vite dev server port (default: 5173)"
    method_option :skip_docker, type: :boolean, default: false,
                                desc: "Skip Docker configuration"
    method_option :locale, type: :string, default: "en",
                           desc: "Default locale (en, it, de, fr, es, pt, nl, pl, ru, ja, zh)"
    def new(app_name)
      pastel = Pastel.new

      # Create configuration
      begin
        config = Configuration.new(
          app_name: app_name,
          rails_port: options[:rails_port],
          vite_port: options[:vite_port],
          locale: options[:locale],
          with_simple_form: options[:with_simple_form],
          skip_docker: options[:skip_docker]
        )
      rescue Error => e
        say pastel.red("Error: #{e.message}")
        exit 1
      end

      # Check if directory already exists
      if Dir.exist?(config.app_path)
        say pastel.red("Error: Directory '#{app_name}' already exists.")
        exit 1
      end

      # Verify dependencies
      checker = DependencyChecker.new
      unless checker.check_all
        say pastel.red("\nMissing required dependencies:")
        checker.missing_dependencies.each { |dep| say pastel.red("  - #{dep}") }
        say pastel.yellow("\nPlease install the missing dependencies and try again.")
        exit 1
      end

      # Generate the application
      say pastel.green("\nGenerating Rails 8 application: #{app_name}\n")

      generator = AppGenerator.new(config)
      generator.generate!

      # Success message
      say pastel.green("\nApplication '#{app_name}' created successfully!")
      say pastel.cyan("\nNext steps:")
      say "  cd #{app_name}"

      if options[:skip_docker]
        say "  bundle install"
        say "  yarn install"
        say "  rails db:create db:schema:load"
        say "  bin/dev              # Start Rails + Vite"
      else
        say "  script/dc-up         # Start Docker containers"
        say "  script/dc-shell      # Open shell in Rails container"
        say "  rails db:create      # Create databases"
        say "  rails db:schema:load # Load schema"
        say "  exit                 # Exit shell"
        say "  script/dc-down && script/dc-up  # Restart containers"
      end

      # Warn if locale doesn't have translation files
      warn_about_missing_locale_files(config.locale, pastel)

      say pastel.cyan("\nHappy coding!")
    end

    desc "check", "Verify that all required dependencies are installed"
    def check
      pastel = Pastel.new
      say pastel.cyan("\nChecking dependencies...\n")

      checker = DependencyChecker.new
      checker.check_all(verbose: true)
    end

    desc "version", "Show better_appgen version"
    def version
      puts "better_appgen v#{VERSION}"
    end

    # Version aliases
    map %w[-v --version] => :version

    # Locales that have translation templates included
    LOCALES_WITH_TEMPLATES = %w[en it].freeze

    private

    def warn_about_missing_locale_files(locale, pastel)
      return if LOCALES_WITH_TEMPLATES.include?(locale)

      say pastel.yellow("\nNote: Locale '#{locale}' does not include translation files.")
      say pastel.yellow("You may want to add translations from the rails-i18n gem:")
      say pastel.yellow("  https://github.com/svenfuchs/rails-i18n")
    end
  end
end
