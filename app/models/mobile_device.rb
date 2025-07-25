class MobileDevice < ApplicationRecord
  belongs_to :mobile_access
  validates :device_token, :external_key, :mobile_access, presence: true

  belongs_to :mobile_user, foreign_key: :external_key, primary_key: :external_key, optional: true

  def attach_topics
    mobile_user.topics.each do |topic|
      Rails.logger.error "Subscribing to topic: #{topic} with device token: #{device_token}"
      mobile_access.notification_service.batch_topic_subscription(topic, [ device_token ])
    end
  end
end
