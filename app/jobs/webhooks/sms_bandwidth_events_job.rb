class Webhooks::SmsBandwidthEventsJob < ApplicationJob
  queue_as :default
  
  SUPPORTED_EVENTS = %w[message-received message-delivered message-failed].freeze
  STATUS = { 'message-delivered' => 'delivered', 'message-failed' => 'failed' }

  def perform(channel, params = {})
    Rails.logger.info("Bandwidth request: #{params}")

    @inbox = channel.inbox
    @body = params['_json']&.first
    return unless SUPPORTED_EVENTS.include?(@body[:type])

    if delivery_event?
      Sms::DeliveryStatusService.new(inbox: @inbox, params: delivery_status.with_indifferent_access).perform
    else
      Sms::IncomingMessageService.new(inbox: @inbox, params: incoming_message.with_indifferent_access).perform
    end
  end

  private

  # Relevant documentation:
  # https://dev.bandwidth.com/docs/mfa/webhooks/international/message-delivered
  # https://dev.bandwidth.com/docs/mfa/webhooks/international/message-failed
  def delivery_status
    {
      "id" => @body[:message][:id],
      "status" => STATUS[@body[:type]],
      "external_error" =>  external_error
    }
  end

  def incoming_message
    {
      "id" => @body[:message][:id],
      "text" => @body[:message][:text],
      "from" => @body[:message][:from],
      "media" => media
    }
  end

  def media
    return if @body[:message][:media].blank?

    files = @body[:message][:media].map do |media_url|
      # we don't need to process this files since chatwoot doesn't support it
      next if media_url.end_with?('.smil', '.xml')

      Down.download(
        media_url,
        http_basic_authentication: [@inbox.channel.provider_config['api_key'], @inbox.channel.provider_config['api_secret']]
      )
    end

    files.compact
  end

  def external_error
    return nil unless error_occurred?

    error_code = @body[:errorCode]
    error_message = @body[:description]
    "#{error_code} - #{error_message}"
  end

  def error_occurred?
    @body[:errorCode] && @body[:type] == 'message-failed'
  end

  def delivery_event?
    @body[:type] == 'message-delivered' || @body[:type] == 'message-failed'
  end

end
