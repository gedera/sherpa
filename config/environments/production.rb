Rails.application.configure do
  config.cache_classes = true

  config.eager_load = true

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # `config/secrets.yml.key`.
  config.read_encrypted_secrets = true

  config.public_file_server.enabled = false

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  config.i18n.fallbacks = false

  config.active_support.deprecation = :notify

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
