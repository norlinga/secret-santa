# frozen_string_literal: true

require 'mail'
require 'erb'

class SantaMailer
  TEMPLATE_PATH = File.expand_path('../templates/email_body.txt.erb', __dir__)

  def initialize(giver:, receiver:, config:)
    @giver = giver
    @receiver = receiver
    @organizer = config.organizer
    @gift_amount = config.gift_amount
    @year = config.year
  end

  def message_body
    template = File.read(TEMPLATE_PATH)
    ERB.new(template).result(binding)
  end

  def send_email
    mail = Mail.new
    mail.from = ENV['EMAIL_USERNAME']
    mail.to = @giver[:email]
    mail.subject = 'You may open this email!'
    mail.body = message_body

    mail.delivery_method :smtp, { address: ENV['EMAIL_SMTP_ADDRESS'],
                                  port: ENV['EMAIL_SMTP_PORT'],
                                  domain: ENV['EMAIL_DOMAIN'],
                                  user_name: ENV['EMAIL_USERNAME'],
                                  password: ENV['EMAIL_PASSWORD'],
                                  enable_ssl: ENV['EMAIL_ENABLE_SSL'] }

    mail.deliver
  end
end
