# frozen_string_literal: true

require 'fileutils'
require 'time'

# Handles persistence of pairing history to disk
class PairingRecorder
  def initialize(base_dir: nil)
    @base_dir = base_dir || ENV['PAIRINGS_DIR'] || File.expand_path('../pairings', __dir__)
  end

  def save(pairings, year)
    dir_path = File.join(@base_dir, year.to_s)
    FileUtils.mkdir_p(dir_path)

    timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
    file_path = File.join(dir_path, "pairings_#{timestamp}.txt")

    write_pairings_file(file_path, pairings, year)

    file_path
  end

  private

  def write_pairings_file(file_path, pairings, year)
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
  end
end
