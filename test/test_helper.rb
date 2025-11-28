# frozen_string_literal: true

require 'dotenv/load'
require 'minitest'
require 'minitest/autorun'
require 'minitest/reporters'

# Require the main application files
require_relative '../lib/colors'
require_relative '../lib/config'

Minitest::Reporters.use! unless Config.live_mode?

require_relative '../lib/secret_santa'
require_relative '../lib/santa_mailer'
require_relative '../lib/pairing_presenter'
require_relative '../lib/pairing_recorder'
require_relative '../lib/email_runner'
