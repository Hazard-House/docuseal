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

    from = message[:from].to_s.presence || 'Haven Sign <noreply@brownhavenhomes.com>'

    $stdout.puts "[Maillayer] deliver! called to=#{message.to.inspect} from=#{from} subject=#{message.subject.inspect}"
    $stdout.flush

    Array(message.to).each do |recipient|
      payload = {
        apiKey: api_key,
        from: from,
        to: recipient,
        subject: message.subject,
        content: html_body(message),
        variables: {}
      }

      $stdout.puts "[Maillayer] POSTing to #{ENDPOINT} for #{recipient}"
      $stdout.flush

      response = Net::HTTP.post(
        ENDPOINT,
        payload.to_json,
        'Content-Type' => 'application/json'
      )

      $stdout.puts "[Maillayer] Response: #{response.code} #{response.body}"
      $stdout.flush

      unless response.is_a?(Net::HTTPSuccess)
        raise "Maillayer delivery failed (#{response.code}): #{response.body}"
      end
    end
  rescue => e
    $stdout.puts "[Maillayer] ERROR: #{e.class}: #{e.message}"
    $stdout.flush
    raise
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
