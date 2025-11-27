# frozen_string_literal: true

require 'dotenv/load'
require 'minitest'
require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use! if ENV['DOITLIVE'] == 'false'

# Require the main application file
require_relative '../lib/secret_santa'
require_relative '../lib/santa_mailer'
