class MobileUser < ApplicationRecord
  belongs_to :mobile_access

  validates :device_group_token, presence: true
  validates :external_key, presence: true, uniqueness: { scope: [ :device_group_token, :mobile_access_id ] }
  validates :topics, presence: true

  has_many :mobile_devices, foreign_key: :external_key, primary_key: :external_key

  after_create :update_topics
  after_update :update_topics, if: :saved_change_to_topics?

  def update_topics
    previous_topics = saved_change_to_topics.first

    if previous_topics.present?
      previous_topics.each do |topic|
        p "Unsubscribing from topic: #{topic} with device tokens: #{device_tokens}"
        notification_service.batch_topic_subscription(topic, device_tokens)
      end
    end

    # Current topics
    topics.each do |topic|
      p "Subscribing to topic: #{topic} with device tokens: #{device_tokens}"
      notification_service.batch_topic_subscription(topic, device_tokens)
    end
  end

  def device_tokens
    mobile_devices.pluck(:device_token).compact
  end

  def notification_service
    @_notification_service ||= mobile_access.notification_service
  end
end
