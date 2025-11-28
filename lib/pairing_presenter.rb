# frozen_string_literal: true

require_relative 'colors'

# Handles console presentation of Secret Santa pairings
class PairingPresenter
  def initialize
    # Could be extended to support different output formats
  end

  def display(pairings, attempts)
    print_header
    pairings.each_with_index do |(giver, receiver), index|
      print_pairing(giver, receiver, index + 1)
    end
    print_footer(attempts)
  end

  private

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
end
