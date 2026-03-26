# Allow server-dang hostname in development and production
# Skip in test to allow www.example.com and localhost
unless Rails.env.test?
  Rails.application.config.hosts << "server-dang"
end
