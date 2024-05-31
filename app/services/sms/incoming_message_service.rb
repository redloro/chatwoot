class Sms::IncomingMessageService
  include ::FileTypeHelper

  pattr_initialize [:inbox!, :params!]

  def perform
    set_contact
    set_conversation
    @message = @conversation.messages.create!(
      content: params[:text],
      account_id: @inbox.account_id,
      inbox_id: @inbox.id,
      message_type: :incoming,
      sender: @contact,
      source_id: params[:id]
    )
    attach_files
    @message.save!
  end

  private

  def account
    @account ||= @inbox.account
  end

  def phone_number
    params[:from]
  end

  def formatted_phone_number
    TelephoneNumber.parse(phone_number).international_number
  end

  def set_contact
    contact_inbox = ::ContactInboxWithContactBuilder.new(
      source_id: params[:from],
      inbox: @inbox,
      contact_attributes: contact_attributes
    ).perform

    @contact_inbox = contact_inbox
    @contact = contact_inbox.contact
  end

  def conversation_params
    {
      account_id: @inbox.account_id,
      inbox_id: @inbox.id,
      contact_id: @contact.id,
      contact_inbox_id: @contact_inbox.id
    }
  end

  def set_conversation
    # if lock to single conversation is disabled, we will create a new conversation if previous conversation is resolved
    @conversation = if @inbox.lock_to_single_conversation
                      @contact_inbox.conversations.last
                    else
                      @contact_inbox.conversations.where
                                    .not(status: :resolved).last
                    end
    return if @conversation

    @conversation = ::Conversation.create!(conversation_params)
  end

  def contact_attributes
    {
      name: formatted_phone_number,
      phone_number: phone_number
    }
  end

  def attach_files
    return if params[:media].blank?

    params[:media].each do |media|
      @message.attachments.new(
        account_id: @message.account_id,
        file_type: file_type(media.content_type),
        file: {
          io: media,
          filename: media.original_filename,
          content_type: media.content_type
        }
      )
    end
  end
end
