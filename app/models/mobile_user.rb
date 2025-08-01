class MobileUser < ApplicationRecord
  belongs_to :mobile_access

  validates :external_key, presence: true, uniqueness: { scope: [ :device_group_token, :mobile_access_id ] }
  validates :topics, presence: true

  has_many :mobile_devices, foreign_key: :external_key, primary_key: :external_key

  after_update :update_topics, if: :saved_change_to_topics?

  delegate :batch_topic_subscription, :batch_topic_unsubscription, :create_notification_key, to: :notification_service

  def update_topics
    previous_topics = saved_change_to_topics&.first || []
    current_topics = topics || []

    # Topics to unsubscribe from (present in previous but not in current)
    topics_to_remove = previous_topics - current_topics
    topics_to_remove.each do |topic|
      Rails.logger.info "Unsubscribing from topic: #{topic} with device tokens: #{device_tokens}"
      batch_topic_unsubscription(topic, device_tokens)
    end

    # Topics to subscribe to (present in current but not in previous)
    topics_to_add = current_topics - previous_topics
    topics_to_add.each do |topic|
      Rails.logger.info "Subscribing to topic: #{topic} with device tokens: #{device_tokens}"
      batch_topic_subscription(topic, device_tokens)
    end
  end

  def device_tokens
    @_device_tokens ||= mobile_devices.pluck(:device_token).compact
  end

  def notification_service
    @_notification_service ||= mobile_access.notification_service
  end

  def create_device_group_token
    device_group_token = create_notification_key(external_key, device_tokens)
    update(device_group_token:) if device_group_token.present?
  end

  def update_device_tokens_in_device_group
    result = notification_service.add(external_key, device_group_token, device_tokens)
    if result&.dig(:notification_key)
      update(device_group_token: result[:notification_key])
      update_device_tokens_in_device_group
    else
      Rails.logger.error "Failed to update device tokens in device group for external_key: #{external_key} and mobile_access_id: #{mobile_access_id}"
    end
  end

  def remove_device_token_from_device_group(registration_ids)
    notification_service.remove(external_key, device_group_token, registration_ids)
  end
end
