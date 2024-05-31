class Webhooks::SmsEventsJob < ApplicationJob
  queue_as :default

  def perform(params = {})
    channel = Channel::Sms.find_by(phone_number: e164_phone_number(params[:phone_number]))
    return unless channel

    process_event_params(channel, params)
  end

  private

  def e164_phone_number(phone_number)
    TelephoneNumber.parse(phone_number).e164_number
  end

  def process_event_params(channel, params)
    case channel.provider
    when 'dialpad'
      Webhooks::SmsDialpadEventsJob.perform_later(channel, params)
    else
      Webhooks::SmsBandwidthEventsJob.perform_later(channel, params)
    end
  end

end
