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

    mobile_devices.each do |device|
      if previous_topics.present?
        previous_topics.each do |topic|
          p "Unsubscribing from topic: #{topic} with external_key: #{device.device_token}"
          notification_service.topic_unsubscription(topic, device.device_token)
        end
      end

      # Current topics
      topics.each do |topic|
        p "Subscribing to topic: #{topic} with external_key: #{device.device_token}"
        notification_service.topic_subscription(topic, device.device_token)
      end
    end
  end

  def notification_service
    @_notification_service ||= mobile_access.notification_service
  end
end
