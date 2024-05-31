#######################################
# To create an sms provider
# - Inherit this as the base class.
# - Implement `send_message` method in your child class.
# - Implement `send_text_message` method in your child class.
# - Implement `validate_provider_config` method in your child class.
# - Use Childclass.new(sms_channel: channel).perform.
######################################

class Sms::Providers::BaseService
  pattr_initialize [:sms_channel!]

  def send_message(_phone_number, _message)
    raise 'Overwrite this method in child class'
  end

  def send_text_message(_phone_number, _message_content)
    raise 'Overwrite this method in child class'
  end

  def validate_provider_config
    raise 'Overwrite this method in child class'
  end
end
