# frozen_string_literal: true

module BetterAppgen
  # Immutable configuration object holding all options for app generation
  class Configuration
    attr_reader :app_name, :rails_port, :vite_port, :locale, :with_simple_form, :skip_docker, :app_path,
                :app_name_snake, :app_name_pascal, :app_name_dash

    # Valid locale codes supported by the generator
    SUPPORTED_LOCALES = %w[en it de fr es pt nl pl ru ja zh].freeze

    def initialize(app_name:, rails_port: 3000, vite_port: 5173, locale: "en",
                   with_simple_form: false, skip_docker: false, app_path: nil)
      @app_name = app_name
      @rails_port = rails_port
      @vite_port = vite_port
      @locale = locale
      @with_simple_form = with_simple_form
      @skip_docker = skip_docker
      @app_path = app_path || File.expand_path(app_name, Dir.pwd)

      # Compute derived values before freezing
      @app_name_snake = app_name.tr("-", "_")
      @app_name_pascal = @app_name_snake.split("_").map(&:capitalize).join
      @app_name_dash = app_name.tr("_", "-")

      validate!
      freeze
    end

    # Returns the timezone based on locale
    def timezone
      case locale
      when "it" then "Europe/Rome"
      when "de" then "Europe/Berlin"
      when "fr" then "Europe/Paris"
      when "es" then "Europe/Madrid"
      when "pt" then "Europe/Lisbon"
      when "nl" then "Europe/Amsterdam"
      when "pl" then "Europe/Warsaw"
      when "ru" then "Europe/Moscow"
      when "ja" then "Asia/Tokyo"
      when "zh" then "Asia/Shanghai"
      else "UTC"
      end
    end

    # Returns a hash representation for template binding
    def to_binding_hash
      {
        app_name: app_name,
        app_name_snake: app_name_snake,
        app_name_pascal: app_name_pascal,
        app_name_dash: app_name_dash,
        rails_port: rails_port,
        vite_port: vite_port,
        locale: locale,
        timezone: timezone,
        with_simple_form: with_simple_form,
        skip_docker: skip_docker
      }
    end

    private

    def validate!
      validate_app_name!
      validate_locale!
      validate_ports!
    end

    def validate_app_name!
      return if app_name.match?(/\A[a-zA-Z][a-zA-Z0-9_-]*\z/)

      raise InvalidAppNameError, app_name
    end

    def validate_locale!
      return if SUPPORTED_LOCALES.include?(locale)

      raise Error, "Unsupported locale '#{locale}'. Supported locales: #{SUPPORTED_LOCALES.join(", ")}"
    end

    def validate_ports!
      raise Error, "Rails port must be between 1024 and 65535" unless (1024..65_535).include?(rails_port)
      raise Error, "Vite port must be between 1024 and 65535" unless (1024..65_535).include?(vite_port)
      raise Error, "Rails port and Vite port must be different" if rails_port == vite_port
    end
  end
end
