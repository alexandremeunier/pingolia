source 'https://rubygems.org'
ruby '2.2.3'


# Stable rails
gem 'rails', '4.2.4'
gem 'pg'
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'responders'
gem 'active_model_serializers', '~> 0.8.0'
gem 'kaminari'
gem 'unicorn'
gem 'sidekiq'


# Assets
gem 'sprockets', '~> 2.0'
gem 'bower-rails'
gem 'angular-rails-templates'
gem 'bootstrap-sass'
gem 'sass-rails'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem 'fuubar'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'better_errors'

  # For db:seed operation
  gem 'ruby-progressbar', require: false
  gem 'parallel', require: false
  gem 'foreman'
  gem 'sinatra', require: nil # For sidekiq monitoring
end

group :test do 
  gem 'factory_girl_rails'
end

