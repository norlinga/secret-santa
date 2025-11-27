# frozen_string_literal: true

require_relative 'test_helper'

# tests to validate SantaMailer class
class SantaMailerTest < Minitest::Test
  def setup
    @giver = { name: 'Alice', email: 'alice@example.com', exclude: ['Bob'] }
    @receiver = { name: 'Bob', email: 'bob@example.com', exclude: ['Alice'] }

    # Create a mock config object
    @config = Minitest::Mock.new
    @config.expect :organizer, { 'name' => 'Sarah', 'email' => 'sarah@example.com' }
    @config.expect :gift_amount, 75
    @config.expect :year, 2025

    @mailer = SantaMailer.new(giver: @giver, receiver: @receiver, config: @config)
  end

  def test_mailer_initializes_with_required_params
    assert_equal 'Alice', @mailer.instance_variable_get(:@giver)[:name]
    assert_equal 'Bob', @mailer.instance_variable_get(:@receiver)[:name]
    assert_equal 75, @mailer.instance_variable_get(:@gift_amount)
    assert_equal 2025, @mailer.instance_variable_get(:@year)
  end

  def test_message_body_includes_giver_name
    message = @mailer.message_body
    assert_includes message, 'Alice', 'Message should include giver name'
  end

  def test_message_body_includes_receiver_name
    message = @mailer.message_body
    assert_includes message, 'Bob', 'Message should include receiver name'
  end

  def test_message_body_includes_organizer_name
    message = @mailer.message_body
    assert_includes message, 'Sarah', 'Message should include organizer name'
  end

  def test_message_body_includes_gift_amount
    message = @mailer.message_body
    assert_includes message, '$75', 'Message should include gift amount'
  end

  def test_message_body_contains_secret_santa_greeting
    message = @mailer.message_body
    assert_includes message, 'Secret Santa', 'Message should mention Secret Santa'
  end

  def test_message_body_has_proper_format
    message = @mailer.message_body
    assert_match(/^Hi Alice!/, message, 'Message should start with greeting')
    assert_includes message, 'You are the Secret Santa for Bob', 'Message should announce pairing'
  end

  def test_different_gift_amount_appears_in_message
    config2 = Minitest::Mock.new
    config2.expect :organizer, { 'name' => 'Sarah', 'email' => 'sarah@example.com' }
    config2.expect :gift_amount, 100
    config2.expect :year, 2025

    mailer2 = SantaMailer.new(giver: @giver, receiver: @receiver, config: config2)
    message = mailer2.message_body

    assert_includes message, '$100', 'Message should include custom gift amount'
    refute_includes message, '$75', 'Message should not include old gift amount'
  end
end
