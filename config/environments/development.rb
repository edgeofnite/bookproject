BooksNew::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  # This is the default, other options are :sendmail and :test
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = {:host => "bookproject.heroku.com"}
  #config.action_mailer.default_url_options = {:host => "localhost:3000"}
  config.action_mailer.smtp_settings = {
    :tls => true,
    :enable_starttls_auto => true,
    :address => "smtp.gmail.com",
    :port => 587,
    :domain => "jaffestrategies.com",
    :authentication => :plain,
    :user_name => "bookproject@jaffestrategies.com",
    :password => "wiiluvbooks"
  }
end

