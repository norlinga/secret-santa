# frozen_string_literal: true

require_relative 'test_helper'
require 'tempfile'
require 'yaml'

# tests to validate Config class
class ConfigTest < Minitest::Test
  def setup
    # Create a temporary config file for testing
    @temp_file = Tempfile.new(['event', '.yml'])
    @config_data = {
      'year' => 2025,
      'gift_amount' => 75,
      'organizer' => {
        'name' => 'Alice',
        'email' => 'alice@example.com'
      },
      'participants' => [
        { 'name' => 'Alice', 'email' => 'alice@example.com', 'exclude' => ['Bob'] },
        { 'name' => 'Bob', 'email' => 'bob@example.com', 'exclude' => ['Alice'] }
      ]
    }
    @temp_file.write(YAML.dump(@config_data))
    @temp_file.rewind
    @config = Config.new(@temp_file.path)
  end

  def teardown
    @temp_file.close
    @temp_file.unlink
  end

  def test_loads_year_from_config
    assert_equal 2025, @config.year
  end

  def test_loads_gift_amount_from_config
    assert_equal 75, @config.gift_amount
  end

  def test_loads_organizer_from_config
    assert_equal 'Alice', @config.organizer['name']
    assert_equal 'alice@example.com', @config.organizer['email']
  end

  def test_loads_participants_from_config
    assert_equal 2, @config.participants.length
    assert_equal 'Alice', @config.participants.first['name']
  end

  def test_gifters_transforms_participants_to_gifter_format
    gifters = @config.gifters

    assert_equal 2, gifters.length
    assert_equal 'Alice', gifters.first[:name]
    assert_equal 'alice@example.com', gifters.first[:email]
    assert_equal ['Bob'], gifters.first[:exclude]
  end

  def test_gifters_handles_missing_exclude_list
    config_data = @config_data.dup
    config_data['participants'] = [
      { 'name' => 'Charlie', 'email' => 'charlie@example.com' }
    ]

    temp_file = Tempfile.new(['event', '.yml'])
    temp_file.write(YAML.dump(config_data))
    temp_file.rewind

    config = Config.new(temp_file.path)
    gifters = config.gifters

    assert_equal [], gifters.first[:exclude]

    temp_file.close
    temp_file.unlink
  end

  def test_raises_error_when_config_file_not_found
    assert_raises RuntimeError do
      Config.new('/nonexistent/path.yml')
    end
  end

  def test_raises_error_when_year_missing
    config_data = @config_data.dup
    config_data.delete('year')

    temp_file = Tempfile.new(['event', '.yml'])
    temp_file.write(YAML.dump(config_data))
    temp_file.rewind

    assert_raises RuntimeError do
      Config.new(temp_file.path)
    end

    temp_file.close
    temp_file.unlink
  end

  def test_raises_error_when_gift_amount_missing
    config_data = @config_data.dup
    config_data.delete('gift_amount')

    temp_file = Tempfile.new(['event', '.yml'])
    temp_file.write(YAML.dump(config_data))
    temp_file.rewind

    assert_raises RuntimeError do
      Config.new(temp_file.path)
    end

    temp_file.close
    temp_file.unlink
  end

  def test_raises_error_when_organizer_missing
    config_data = @config_data.dup
    config_data.delete('organizer')

    temp_file = Tempfile.new(['event', '.yml'])
    temp_file.write(YAML.dump(config_data))
    temp_file.rewind

    assert_raises RuntimeError do
      Config.new(temp_file.path)
    end

    temp_file.close
    temp_file.unlink
  end

  def test_raises_error_when_participants_missing
    config_data = @config_data.dup
    config_data.delete('participants')

    temp_file = Tempfile.new(['event', '.yml'])
    temp_file.write(YAML.dump(config_data))
    temp_file.rewind

    assert_raises RuntimeError do
      Config.new(temp_file.path)
    end

    temp_file.close
    temp_file.unlink
  end

  def test_raises_error_when_participants_empty
    config_data = @config_data.dup
    config_data['participants'] = []

    temp_file = Tempfile.new(['event', '.yml'])
    temp_file.write(YAML.dump(config_data))
    temp_file.rewind

    assert_raises RuntimeError do
      Config.new(temp_file.path)
    end

    temp_file.close
    temp_file.unlink
  end
end
