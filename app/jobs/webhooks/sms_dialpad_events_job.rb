class Webhooks::SmsDialpadEventsJob < ApplicationJob
  queue_as :default

  SUPPORTED_EVENTS = %w[pending sent delivered failed].freeze
  STATUS = { 'sent' => 'sent', 'delivered' => 'delivered', 'failed' => 'failed' }

  def perform(channel, params = {})
    Rails.logger.info("dialpad request: #{params}")

    @inbox = channel.inbox
    @body = params
    return unless SUPPORTED_EVENTS.include?(@body[:message_status])

    if delivery_event?
      return unless STATUS.include?(@body[:message_status])
      Sms::DeliveryStatusService.new(inbox: @inbox, params: delivery_status.with_indifferent_access).perform
    else
      Sms::IncomingMessageService.new(inbox: @inbox, params: incoming_message.with_indifferent_access).perform
    end
  end

  private

  # Relevant documentation:
  # https://developers.dialpad.com/reference/smssend
  # https://developers.dialpad.com/docs/sms-events
  # https://developers.dialpad.com/reference/webhook_sms_event_subscriptioncreate
  def delivery_status
    {
      "id" => @body[:id],
      "status" => STATUS[@body[:message_status]],
      "external_error" =>  external_error
    }
  end

  def incoming_message
    {
      "id" => @body[:id],
      "text" => @body[:text],
      "from" => @body[:from_number],
      "media" => media
    }
  end

  def media
    return unless mms?
    [].push(Down.download(@body[:mms_url]))
  end

  def external_error
    return nil unless error_occurred?

    error_code = @body[:message_status]
    error_message = @body[:message_delivery_result]
    "#{error_code} - #{error_message}"
  end

  def mms?
    @body[:mms] == true
  end

  def error_occurred?
    @body[:message_status] == 'failed'
  end

  def delivery_event?
    @body[:direction] == 'outbound'
  end

end
