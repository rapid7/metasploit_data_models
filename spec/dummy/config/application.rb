require File.expand_path('../boot', __FILE__)
require "logger"
require "active_support"
require 'rails/all'

Bundler.require(*Rails.groups)
# require the engine being tested.  In a non-dummy app this would be handled by the engine's gem being in the Gemfile
# for real app and Bundler.require requiring the gem.
require 'metasploit_data_models'
require 'metasploit_data_models/engine'
require 'metasploit/concern/engine'
require 'metasploit/model/engine'

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Raise deprecations as errors
    config.active_support.deprecation = :raise

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    config.active_record.yaml_column_permitted_classes = MetasploitDataModels::YAML::PERMITTED_CLASSES

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    config.active_record.schema_format = :sql

    # 5.x change to belongs_to
    config.active_record.belongs_to_required_by_default = true

    config.autoloader = :zeitwerk
  end
end

