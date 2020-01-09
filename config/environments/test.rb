Rails.application.configure do
  config.cache_classes = true

  config.eager_load = true

  config.public_file_server.enabled = false

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_dispatch.show_exceptions = false

  config.action_controller.allow_forgery_protection = false

  config.active_support.deprecation = :stderr
end
