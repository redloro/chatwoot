class Sms::Providers::SmsDialpadService < Sms::Providers::BaseService
  def send_message(contact_number, message)
    body = message_body(contact_number, message.content)
    return send(body) unless message.attachments.present?

    response = message.attachments.map do |attachment|
      image = HTTParty.get(attachment.download_url)
      body['media'] = Base64.strict_encode64(image)
      send(body)
    end

    response.first
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
      headers: { 'Content-Type' => 'application/json', 'Authorization' => auth },
    )
    response.success?
  end

  private

  def api_base_path
    'https://dialpad.com/api/v2'
  end

  def auth
    "Bearer #{sms_channel.provider_config['api_key']}"
  end

  def message_body(contact_number, message_content)
    {
      'to_numbers' => [contact_number],
      'from_number' => sms_channel.phone_number,
      'text' => message_content,
      'infer_country_code': false
    }
  end

  def send(body)
    response = HTTParty.post(
      "#{api_base_path}/sms",
      headers: { 'Content-Type' => 'application/json', 'Authorization' => auth },
      body: body.to_json
    )

    response.success? ? response.parsed_response['id'] : nil
  end
end
