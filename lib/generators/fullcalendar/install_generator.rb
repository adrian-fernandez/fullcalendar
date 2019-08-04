require 'rails/generators'

module Fullcalendar
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc "This generator installs fullcalendar to the rails asset pipeline"

      argument :style, :type => :string, :default => 'default'
      # needed for thor templates
      source_root File.expand_path("../templates", __FILE__)

      def add_assets
        js_manifest = 'app/assets/javascripts/application.js'
        css_manifest = 'app/assets/stylesheets/application.css'
        scss_manifest = 'app/assets/stylesheets/application.scss'
        js_strings = "//= require calendar\n"

        insert_into_file js_manifest, js_strings, :after => "turbolinks\n" if File.exists?(js_manifest)
        insert_css_strings(css_manifest) if File.exists?(css_manifest)
        insert_scss_strings(scss_manifest) if File.exists?(scss_manifest)
        copy_core_file
      end

      private

      def insert_css_strings(css_manifest)
        content = File.read(css_manifest)
        css_strings = "*/= require calendar\n"

        if requires_tree(content)
          insert_into_file css_manifest, css_strings, :after => "require_tree .\n"
        elsif requires_self(content)
          insert_into_file css_manifest, css_strings, :before => " *= require_self\n"
        else
          insert_into_file css_manifest, css_strings, :before => " */"
        end

      end

      def insert_scss_strings(scss_manifest)
        content = File.read(scss_manifest)
        scss_strings = "\n@import \"calendar\";\n"
        append_to_file scss_manifest, scss_strings
      end

      def requires_tree(content)
        content.match(/require_tree\s+\.\s*$/)
      end

      def requires_self(content)
        content.match(/require_self\s*$/)
      end

      def copy_core_file
        template "#{style}.js.tt", "app/assets/javascripts/calendar.js"
        template "#{style}.scss.tt", "app/assets/stylesheets/calendar.scss"
      end

    end
  end
end
