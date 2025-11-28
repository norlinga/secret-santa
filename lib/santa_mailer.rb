# frozen_string_literal: true

require 'mail'
require 'erb'

# Does the mailing of assignment emails
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
    mail.from = ENV.fetch('EMAIL_USERNAME', nil)
    mail.to = @giver[:email]
    mail.subject = 'You may open this email!'
    mail.body = message_body

    mail.delivery_method :smtp, { address: ENV.fetch('EMAIL_SMTP_ADDRESS', nil),
                                  port: ENV.fetch('EMAIL_SMTP_PORT', nil),
                                  domain: ENV.fetch('EMAIL_DOMAIN', nil),
                                  user_name: ENV.fetch('EMAIL_USERNAME', nil),
                                  password: ENV.fetch('EMAIL_PASSWORD', nil),
                                  enable_ssl: ENV.fetch('EMAIL_ENABLE_SSL', nil) }

    mail.deliver
  end
end
