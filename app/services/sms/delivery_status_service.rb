class Sms::DeliveryStatusService
  pattr_initialize [:inbox!, :params!]

  def perform
    process_status if message.present?
  end

  private

  def process_status
    @message.status = params[:status]
    @message.external_error = params[:external_error]
    @message.save!
  end

  def message
    return unless params[:id]

    @message ||= inbox.messages.find_by(source_id: params[:id])
  end
end
