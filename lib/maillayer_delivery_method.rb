# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

class MaillayerDeliveryMethod
  ENDPOINT = URI('https://mailer.hazardhouse.ai/api/transactional/send').freeze

  attr_reader :settings

  def initialize(settings = {})
    @settings = settings
  end

  def deliver!(message)
    api_key = settings[:api_key] || ENV.fetch('MAILLAYER_API_KEY')

    Array(message.to).each do |recipient|
      payload = {
        apiKey: api_key,
        from: 'noreply@brownhavenhomes.com',
        to: recipient,
        variables: {
          subject: message.subject,
          html: html_body(message)
        }
      }

      response = Net::HTTP.post(
        ENDPOINT,
        payload.to_json,
        'Content-Type' => 'application/json'
      )

      unless response.is_a?(Net::HTTPSuccess)
        raise "Maillayer delivery failed (#{response.code}): #{response.body}"
      end
    end
  end

  private

  def html_body(message)
    if message.html_part
      message.html_part.body.decoded
    elsif message.content_type&.include?('text/html')
      message.body.decoded
    else
      message.body.to_s
    end
  end
end
