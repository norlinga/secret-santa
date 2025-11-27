# frozen_string_literal: true

require 'dotenv/load'
require_relative 'lib/config'
require_relative 'lib/secret_santa'
require_relative 'lib/santa_mailer'

# ANSI color codes for festive output
module Colors
  RED = "\e[31m"
  GREEN = "\e[32m"
  YELLOW = "\e[33m"
  BOLD = "\e[1m"
  RESET = "\e[0m"
end

def print_header
  puts "\n#{Colors::GREEN}#{Colors::BOLD}🎄 ═══════════════════════════════════════════ 🎄#{Colors::RESET}"
  puts "#{Colors::RED}#{Colors::BOLD}        Secret Santa Pairing Results!        #{Colors::RESET}"
  puts "#{Colors::GREEN}#{Colors::BOLD}🎄 ═══════════════════════════════════════════ 🎄#{Colors::RESET}\n\n"
end

def print_pairing(giver, receiver, index)
  puts "#{Colors::YELLOW}#{Colors::BOLD}Gift ##{index}:#{Colors::RESET}"
  puts "  #{Colors::GREEN}🎁 #{giver[:name]}#{Colors::RESET} → #{Colors::RED}#{receiver[:name]}#{Colors::RESET}"
  puts ''
end

def print_footer(attempts)
  puts "#{Colors::GREEN}#{Colors::BOLD}🎄 ═══════════════════════════════════════════ 🎄#{Colors::RESET}"
  puts "#{Colors::YELLOW}✨ Pairings generated in #{attempts} attempt(s)! ✨#{Colors::RESET}"
  puts "#{Colors::GREEN}#{Colors::BOLD}🎄 ═══════════════════════════════════════════ 🎄#{Colors::RESET}\n\n"
end

def display_pairings(pairings, attempts)
  print_header
  pairings.each_with_index do |(giver, receiver), index|
    print_pairing(giver, receiver, index + 1)
  end
  print_footer(attempts)
end

def save_pairings(pairings, year)
  require 'fileutils'
  require 'time'

  dir_path = File.expand_path("../pairings/#{year}", __dir__)
  FileUtils.mkdir_p(dir_path)

  timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
  file_path = File.join(dir_path, "pairings_#{timestamp}.txt")

  File.open(file_path, 'w') do |f|
    f.puts "Secret Santa Pairings - #{year}"
    f.puts "Generated: #{Time.now}"
    f.puts '=' * 50
    f.puts ''

    pairings.each_with_index do |(giver, receiver), index|
      f.puts "Gift ##{index + 1}:"
      f.puts "  #{giver[:name]} (#{giver[:email]}) → #{receiver[:name]} (#{receiver[:email]})"
      f.puts ''
    end
  end

  file_path
end

def send_emails(pairings, year, config)
  puts "\n#{Colors::RED}#{Colors::BOLD}📧 Sending emails...#{Colors::RESET}\n\n"
  pairings.each do |giver, receiver|
    puts "#{Colors::GREEN}Sending to #{giver[:name]}...#{Colors::RESET}"
    SantaMailer.new(giver:, receiver:, config:).send_email
    sleep 3
  end
  puts "\n#{Colors::GREEN}#{Colors::BOLD}✅ All emails sent successfully!#{Colors::RESET}\n"

  # Save pairings to file
  file_path = save_pairings(pairings, year)
  puts "#{Colors::YELLOW}💾 Pairings saved to: #{file_path}#{Colors::RESET}\n"
end

# Main execution
config = Config.new
gifters = config.gifters
secret_santa = SecretSanta.new(gifters:)
pairings = secret_santa.pair_gifters

if ENV['DOITLIVE'] == 'true'
  send_emails(pairings, config.year, config)
else
  display_pairings(pairings, secret_santa.attempts)
  puts "#{Colors::YELLOW}💡 Tip: Set DOITLIVE=true to send emails#{Colors::RESET}\n"
end
