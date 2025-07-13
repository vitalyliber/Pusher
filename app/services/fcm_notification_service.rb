require "fcm"

class FcmNotificationService
  def initialize(service_account)
    parsed_service_account = JSON.parse(service_account) if service_account.is_a?(String)
    @fcm = FCM.new(StringIO.new(service_account), parsed_service_account["project_id"])
  end

  def send_notification(data:, topic:, external_key:)
    data = JSON.parse(data) if data.is_a?(String)

    if topic.present?
      send_to_topic(topic, data)
    else
      token = MobileDevice.where(external_key:).pluck(:device_token).first || "xxx"

      return unless token.present?

      send_to_device(data.merge(token:))
    end
  rescue StandardError => e
    Rails.logger.error "Error sending FCM notification: #{e.message}"
    { success: false, error: e.message }
  end

  private

  def send_to_topic(topic, payload)
    response = @fcm.send_to_topic(topic, payload)
    Rails.logger.info "FCM notification sent to topic: #{response}"
    { success: true, response: response }
  end

  def send_to_device(payload)
    response = @fcm.send_v1(payload)
    Rails.logger.info "FCM notification sent to device: #{response}"
    { success: true, response: response }
  end
end
