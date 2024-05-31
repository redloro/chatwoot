class Sms::Providers::SmsBandwidthService < Sms::Providers::BaseService
  def send_message(contact_number, message)
    body = message_body(contact_number, message.content)
    body['media'] = message.attachments.map(&:download_url) if message.attachments.present?
    send(body)
  end

  def send_text_message(contact_number, message_content)
    body = message_body(contact_number, message_content)
    send(body)
  end

  # Extract later into provider Service
  # let's revisit later
  def validate_provider_config
    response = HTTParty.post(
      "#{api_base_path}/users/#{sms_channel.provider_config['account_id']}/messages",
      basic_auth: auth,
      headers: { 'Content-Type': 'application/json' }
    )
    response.success?
  end

  private

  def api_base_path
    'https://messaging.bandwidth.com/api/v2'
  end

  def auth
    { username: sms_channel.provider_config['api_key'], password: sms_channel.provider_config['api_secret'] }
  end

  def message_body(contact_number, message_content)
    {
      'to' => contact_number,
      'from' => sms_channel.phone_number,
      'text' => message_content,
      'applicationId' => sms_channel.provider_config['application_id']
    }
  end

  def send(body)
    response = HTTParty.post(
      "#{api_base_path}/users/#{sms_channel.provider_config['account_id']}/messages",
      basic_auth: auth,
      headers: { 'Content-Type' => 'application/json' },
      body: body.to_json
    )

    response.success? ? response.parsed_response['id'] : nil
  end
end
