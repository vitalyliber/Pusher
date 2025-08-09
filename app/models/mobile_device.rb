class MobileDevice < ApplicationRecord
  include PgSearch::Model

  belongs_to :mobile_access
  validates :device_token, :external_key, :mobile_access, presence: true

  belongs_to :mobile_user, foreign_key: :external_key, primary_key: :external_key, optional: true

  pg_search_scope :search_by_info,
                  against: [ :device_info, :user_info ],
                  using: {
                    tsearch: { prefix: true, dictionary: "english" }
                  }

  def subscribe_to_topics
    mobile_user.topics.each do |topic|
      Rails.logger.error "Subscribing to topic: #{topic} with device token: #{device_token}"
      mobile_access.notification_service.batch_topic_subscription(topic, [ device_token ])
    end
  end

  def unsubscribe_from_topics
    mobile_user.topics.each do |topic|
      Rails.logger.info "Unsubscribing from topic: #{topic} with device token: #{device_token}"

      mobile_access.notification_service.batch_topic_unsubscription(topic, [ device_token ])
    end
  end

  def unsubscribe_from_unregistered_topic
    Rails.logger.error "Unsubscribing from 'unregistered' and 'general' topics for device token: #{device_token}"
    mobile_access.notification_service.batch_topic_unsubscription("unregistered", [ device_token ])
  end
end
