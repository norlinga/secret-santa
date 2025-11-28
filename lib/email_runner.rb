# frozen_string_literal: true

require_relative 'colors'
require_relative 'santa_mailer'
require_relative 'pairing_recorder'

# Orchestrates sending emails and recording pairings
class EmailRunner
  def initialize(config:, recorder: nil)
    @config = config
    @recorder = recorder || PairingRecorder.new
  end

  def run(pairings)
    print_start_message
    send_all_emails(pairings)
    print_success_message
    save_and_report(pairings)
  end

  private

  def print_start_message
    puts "\n#{Colors::RED}#{Colors::BOLD}📧 Sending emails...#{Colors::RESET}\n\n"
  end

  def send_all_emails(pairings)
    pairings.each do |giver, receiver|
      puts "#{Colors::GREEN}Sending to #{giver[:name]}...#{Colors::RESET}"
      SantaMailer.new(giver:, receiver:, config: @config).send_email
      sleep 3 if Config.live_mode?
    end
  end

  def print_success_message
    puts "\n#{Colors::GREEN}#{Colors::BOLD}✅ All emails sent successfully!#{Colors::RESET}\n"
  end

  def save_and_report(pairings)
    file_path = @recorder.save(pairings, @config.year)
    puts "#{Colors::YELLOW}💾 Pairings saved to: #{file_path}#{Colors::RESET}\n"
  end
end
