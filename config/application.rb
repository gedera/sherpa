require_relative 'boot'

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "rails/test_unit/railtie"
require 'net/http'

Bundler.require(*Rails.groups)

module Sherpa
  class Application < Rails::Application
    config.api_only = true
    config.load_defaults 5.2
    config.time_zone = 'UTC'
    config.eager_load_paths << Rails.root.join('lib').to_s
    config.autoload_paths += Dir[Rails.root.join('lib', '{daemons/}')]
    # config.eager_load_paths << Rails.root.join('lib/adapters')
    # config.logger = WisproUtils::Logger.new(name: 'sherpa')
    # config.log_level = ENV['LOG_LEVEL'] || :debug
  end
end
