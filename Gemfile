# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'minitest'
gem 'minitest-reporters'

gem 'guard'
gem 'guard-minitest'

gem 'dotenv'

gem 'mail', '~> 2.8'

group :development, :test do
  gem 'rubocop', '~> 1.57'
  gem 'rubocop-minitest', require: false
end

group :test do
  gem 'faker', '~> 3.2'
end
