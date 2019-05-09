I18n.available_locales = ['en', 'es']
I18n.config.default_locale = 'es'
I18n.config.enforce_available_locales = true
I18n.config.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}')]
