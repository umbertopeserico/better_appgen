# frozen_string_literal: true

module BetterAppgen
  module Generators
    # Sets up Vite 7 + Tailwind CSS 4 + Stimulus
    class Vite < Base
      DEPENDENCIES = {
        "@hotwired/stimulus" => "^3.2.2",
        "@hotwired/turbo-rails" => "^8.0.12"
      }.freeze

      DEV_DEPENDENCIES = {
        "@tailwindcss/postcss" => "^4.0.0",
        "autoprefixer" => "^10.4.20",
        "postcss" => "^8.5.1",
        "tailwindcss" => "^4.0.0",
        "vite" => "^6.0.7"
      }.freeze

      SCRIPTS = {
        "dev" => "vite --host 0.0.0.0 --port 5173",
        "build" => "vite build"
      }.freeze

      def generate!
        setup_directories
        setup_package_json
        create_vite_config
        create_postcss_config
        create_stylesheets
        create_javascript
        create_vite_helper
        create_procfile
        create_bin_dev
        create_yarnrc
        create_gitignore
        create_env_files
        create_layout
      end

      private

      def setup_directories
        create_directory("app/assets/images")
        create_directory("app/assets/javascripts/controllers")
        create_directory("app/assets/stylesheets")

        # Remove default application.css if exists
        css_file = File.join(app_path, "app/assets/stylesheets/application.css")
        FileUtils.rm_f(css_file)
      end

      def setup_package_json
        scripts = SCRIPTS.dup
        scripts["dev"] = "vite --host 0.0.0.0 --port #{vite_port}"

        merge_package_json(
          dependencies: DEPENDENCIES,
          dev_dependencies: DEV_DEPENDENCIES,
          scripts: scripts,
          extra: {
            "type" => "module",
            "packageManager" => "yarn@4.5.3"
          }
        )
      end

      def create_vite_config
        create_file_from_template("vite.config.js", "vite/vite.config.js.erb")
      end

      def create_postcss_config
        create_file_from_template("postcss.config.js", "vite/postcss.config.js.erb")
      end

      def create_stylesheets
        create_file_from_template("app/assets/stylesheets/application.css", "vite/application.css.erb")
      end

      def create_javascript
        create_file_from_template("app/assets/javascripts/application.js", "vite/application.js.erb")
        create_file_from_template("app/assets/javascripts/controllers/application.js",
                                  "vite/controllers/application.js.erb")
        create_file_from_template("app/assets/javascripts/controllers/hello_controller.js",
                                  "vite/controllers/hello_controller.js.erb")
        create_file_from_template("app/assets/javascripts/controllers/index.js", "vite/controllers/index.js.erb")
      end

      def create_vite_helper
        create_file_from_template("app/helpers/vite_helper.rb", "vite/vite_helper.rb.erb")
      end

      def create_procfile
        create_file_from_template("Procfile.dev", "root/Procfile.dev.erb")
      end

      def create_bin_dev
        create_file_from_template("bin/dev", "bin/dev.erb")
        chmod_executable("bin/dev")
      end

      def create_yarnrc
        create_file_from_template(".yarnrc.yml", "root/yarnrc.yml.erb")
      end

      def create_gitignore
        create_file_from_template(".gitignore", "root/gitignore.erb")
      end

      def create_env_files
        create_file_from_template(".env.example", "root/env.example.erb")
        create_file_from_template(".env", "root/env.example.erb")
      end

      def create_layout
        create_file_from_template("app/views/layouts/application.html.erb",
                                  "app/views/layouts/application.html.erb.erb")
      end
    end
  end
end
