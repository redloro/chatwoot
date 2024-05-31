# == Schema Information
#
# Table name: channel_sms
#
#  id              :bigint           not null, primary key
#  phone_number    :string           not null
#  provider        :string           default("default")
#  provider_config :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :integer          not null
#
# Indexes
#
#  index_channel_sms_on_phone_number  (phone_number) UNIQUE
#

class Channel::Sms < ApplicationRecord
  include Channelable

  self.table_name = 'channel_sms'
  EDITABLE_ATTRS = [:phone_number, :provider, { provider_config: {} }].freeze

  # default at the moment is bandwidth lets change later.
  PROVIDERS = %w[default dialpad].freeze

  validates :provider, inclusion: { in: PROVIDERS }
  validates :phone_number, presence: true, uniqueness: true
  # before_save :validate_provider_config

  def name
    'Sms'
  end

  def provider_service
    if provider == 'dialpad'
      Sms::Providers::SmsDialpadService.new(sms_channel: self)
    else
      Sms::Providers::SmsBandwidthService.new(sms_channel: self)
    end
  end

  delegate :send_message, to: :provider_service
  delegate :send_text_message, to: :provider_service
  #delegate :validate_provider_config, to: :provider_service
end
