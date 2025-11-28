# frozen_string_literal: true

require 'dotenv/load'
require_relative 'lib/config'
require_relative 'lib/secret_santa'
require_relative 'lib/colors'
require_relative 'lib/pairing_presenter'
require_relative 'lib/email_runner'

# Main execution
config = Config.new
gifters = config.gifters
secret_santa = SecretSanta.new(gifters:)
pairings = secret_santa.pair_gifters

if Config.live_mode?
  EmailRunner.new(config:).run(pairings)
else
  PairingPresenter.new.display(pairings, secret_santa.attempts)
  puts "#{Colors::YELLOW}💡 Tip: Set DOITLIVE=true to send emails#{Colors::RESET}\n"
end
