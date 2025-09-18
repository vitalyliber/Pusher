class MobileUser < ApplicationRecord
  belongs_to :mobile_access

  validates :external_key, presence: true, uniqueness: { scope: [ :device_group_token, :mobile_access_id ] }
  validates :topics, presence: true

  has_many :mobile_devices, foreign_key: :external_key, primary_key: :external_key

  delegate :create_notification_key, to: :notification_service

  def firebase_device_tokens
    @_device_tokens ||= mobile_devices.firebase.pluck(:device_token).compact
  end

  def huawei_device_tokens
    @_device_tokens ||= mobile_devices.huawei.pluck(:device_token).compact
  end

  def notification_service
    @_notification_service ||= mobile_access.notification_service
  end

  def create_device_group_token
    return if firebase_device_tokens.empty?

    device_group_token = create_notification_key(external_key, firebase_device_tokens)
    update(device_group_token:) if device_group_token.present?
  end

  def update_device_tokens_in_device_group
    return if firebase_device_tokens.empty?

    result = notification_service.add(external_key, device_group_token, firebase_device_tokens)
    if result&.dig(:notification_key)
      update(device_group_token: result[:notification_key])

      # Don't remember why I call it again
      update_device_tokens_in_device_group
    else
      Rails.logger.error "Failed to update device tokens in device group for external_key: #{external_key} and mobile_access_id: #{mobile_access_id}"
    end
  end

  def remove_device_token_from_device_group(registration_ids)
    notification_service.remove(external_key, device_group_token, registration_ids)
  end
end
