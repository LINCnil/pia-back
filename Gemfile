source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'fast_jsonapi'
gem 'rails', '~> 7.0.3'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'mime-types', '~> 3.3'
gem 'puma', '~> 5.6'

gem 'carrierwave'
gem 'carrierwave-base64'
gem 'dotenv-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.13'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.5', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'
gem 'rack-cors', require: 'rack/cors'

gem 'devise'
gem 'devise_ldap_authenticatable'
gem 'devise-security'

gem 'doorkeeper'
gem 'pundit'

# i18n gems
gem 'devise-i18n'
gem 'doorkeeper-i18n'
gem 'rails-i18n'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'byebug', platform: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'rubocop'
  gem 'rubocop-rails', require: false
end

group :development do
  # gem 'listen', '~> 3.2.1'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
  # gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem "rubocop-rails-omakase", require: false, group: [ :development ]

gem 'simplecov', require: false, group: :test
