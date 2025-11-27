# frozen_string_literal: true

require 'dotenv/load'
require 'minitest'
require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use! if ENV['DOITLIVE'] == 'false'

require 'mail'

# tests to validate SecretSanta class
class SecretSantaTest < Minitest::Test
  def setup
    @gifters = [
      { name: 'Alice', email: 'alice@example.com', exclude: ['Bob'] },
      { name: 'Bob', email: 'bob@example.com', exclude: ['Alice'] },
      { name: 'Charlie', email: 'charlie@example.com', exclude: ['Diana'] },
      { name: 'Diana', email: 'diana@example.com', exclude: ['Charlie'] },
      { name: 'Eve', email: 'eve@example.com', exclude: ['Frank'] },
      { name: 'Frank', email: 'frank@example.com', exclude: ['Eve'] }
    ]

    @valid_pairings = [
      [{ name: 'Alice', email: '', exclude: ['Bob'] },
       { name: 'Charlie', email: '', exclude: ['Diana'] }],
      [{ name: 'Bob', email: '', exclude: ['Alice'] },
       { name: 'Diana', email: '', exclude: ['Charlie'] }]
    ]

    @invalid_pairing_1 = [
      [{ name: 'Alice', email: '', exclude: ['Bob'] },
       { name: 'Alice', email: '', exclude: ['Bob'] }],
      [{ name: 'Bob', email: '', exclude: ['Alice'] },
       { name: 'Charlie', email: '', exclude: ['Diana'] }]
    ]

    @invalid_pairing_2 = [
      [{ name: 'Alice', email: '', exclude: ['Bob'] },
       { name: 'Bob', email: '', exclude: ['Alice'] }],
      [{ name: 'Bob', email: '', exclude: ['Alice'] },
       { name: 'Charlie', email: '', exclude: ['Diana'] }]
    ]
  end

  def test_default_env_value
    assert_equal 'test', ENV['TEST_VALUE']
  end

  def test_new_requires_gifter_array
    assert_raises ArgumentError do
      SecretSanta.new
    end
  end

  def test_suffle_gifters_returns_array_of_arrays
    secret_santa = SecretSanta.new(gifters: @gifters)
    assert_equal Array, secret_santa.send(:shuffle_gifters).class
    assert !secret_santa.instance_variable_get(:@pairings).nil?
  end

  def test_pairings_valid_returns_true_for_valid_pairings
    secret_santa = SecretSanta.new(gifters: @gifters)
    secret_santa.instance_variable_set(:@pairings, @valid_pairings)
    assert secret_santa.send(:pairings_valid?)
  end

  def test_pairings_valid_returns_false_for_invalid_pairings
    secret_santa = SecretSanta.new(gifters: @gifters)
    secret_santa.instance_variable_set(:@pairings, @invalid_pairing_1)
    assert !secret_santa.send(:pairings_valid?)
    secret_santa.instance_variable_set(:@pairings, @invalid_pairing_2)
    assert !secret_santa.send(:pairings_valid?)
  end
end

# Provide an array of gifters as {name:, email:, exclude: []}
# to SecretSanta.new(gifters:)
# Then #pair_gifters will return an array of arrays of paired gifters
# as [[giver, receiver], [giver, receiver], ...]
class SecretSanta
  attr_reader :attempts

  def initialize(gifters:)
    @gifters = gifters
    @pairings = []
    @attempts = 0
  end

  def pair_gifters
    shuffle_gifters
    pairings_valid? ? @pairings : pair_gifters
  end

  private

  def shuffle_gifters
    @pairings = @gifters.zip(@gifters.shuffle)
  end

  def pairings_valid?
    @attempts += 1
    @pairings.all? do |giver, receiver|
      giver_name = giver[:name]
      receiver_name = receiver[:name]
      exclude_list = giver[:exclude]

      giver_name != receiver_name && !exclude_list.include?(receiver_name)
    end
  end
end

class MyMailer
  def initialize(giver:, receiver:)
    puts giver
    puts receiver
    @giver = giver
    @receiver = receiver
    puts @giver.inspect
    puts @receiver.inspect
  end

  def parse_message
    <<~BODY
      Hi #{@giver[:name]}!

      It's that time of year again!  You are the Secret Santa for #{@receiver[:name]}!  As the name implies, this is a secret so please do not tell your giftee.

      What does this mean?  We Norling siblings and spouses are each responsible for ONE gift for ONE sibling or spouse this year.  This email is your gifting assignment.  If you fail this task, #{@receiver[:name]} literally gets nothing and will have a horrible Christmas and it'll be your fault.  No pressure.  The gift exchange will take place sometime around Christmas-ish.  Maybe a few days after?  Or a few days before?  Who knows, but it'll be great!  Please be ready with your wrapped gift valued at $75 or less.

      Any further questions about this event, ask Alice.  But don't let her know if you're her Secret Santa.  Anyhow, she mastermind-ed this whole thing last year and can answer any questions again this year.

      Cheers from your Happy Secret Santa Pairing Bot!
    BODY
  end

  def send_emails
    mail = Mail.new
    mail.from = ENV['EMAIL_USERNAME']
    mail.to = @giver[:email]
    mail.subject = 'You may open this email!'
    mail.body = parse_message

    mail.delivery_method :smtp, { address: ENV['EMAIL_SMTP_ADDRESS'],
                                  port: ENV['EMAIL_SMTP_PORT'],
                                  domain: ENV['EMAIL_DOMAIN'],
                                  user_name: ENV['EMAIL_USERNAME'],
                                  password: ENV['EMAIL_PASSWORD'],
                                  enable_ssl: ENV['EMAIL_ENABLE_SSL'] }

    # puts mail.inspect
    mail.deliver
  end
end

gifters = [
  { name: 'Alice', email: 'alice@example.com', exclude: %w[Bob] },
  { name: 'Bob', email: 'bob@example.com', exclude: %w[Alice Charlie] },
  { name: 'Charlie', email: 'charlie@example.com', exclude: %w[Diana] },
  { name: 'Diana', email: 'diana@example.com', exclude: %w[Charlie Alice] },
  { name: 'Eve', email: 'eve@example.com', exclude: %w[Frank Bob] },
  { name: 'Frank', email: 'frank@example.com', exclude: %w[Eve] }
]

if ENV['DOITLIVE'] == 'true'
  secret_santa = SecretSanta.new(gifters:)
  secret_santa.pair_gifters.each do |giver, receiver|
    MyMailer.new(giver:, receiver:).send_emails
    sleep 3
  end
end
