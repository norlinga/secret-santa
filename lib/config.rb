# frozen_string_literal: true

require 'yaml'

# Loads and provides access to the Secret Santa event configuration
class Config
  attr_reader :year, :gift_amount, :organizer, :participants

  def initialize(config_path = nil)
    @config_path = config_path || default_config_path
    load_config
  end

  def gifters
    @participants.map do |participant|
      {
        name: participant['name'],
        email: participant['email'],
        exclude: participant['exclude'] || []
      }
    end
  end

  private

  def default_config_path
    File.expand_path('../config/event.yml', __dir__)
  end

  def load_config
    raise "Configuration file not found: #{@config_path}" unless File.exist?(@config_path)

    config = YAML.load_file(@config_path)

    @year = config['year']
    @gift_amount = config['gift_amount']
    @organizer = config['organizer']
    @participants = config['participants']

    validate_config
  end

  def validate_config
    raise 'Configuration must include year' unless @year
    raise 'Configuration must include gift_amount' unless @gift_amount
    raise 'Configuration must include organizer' unless @organizer
    raise 'Configuration must include participants' unless @participants&.any?
  end
end
