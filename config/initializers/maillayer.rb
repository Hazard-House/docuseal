# frozen_string_literal: true

require_relative '../../lib/maillayer_delivery_method'

ActionMailer::Base.add_delivery_method :maillayer, MaillayerDeliveryMethod,
                                       api_key: ENV.fetch('MAILLAYER_API_KEY', nil)
