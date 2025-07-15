require "fcm"

class FcmNotificationService
  def initialize(service_account)
    parsed_service_account = JSON.parse(service_account) if service_account.is_a?(String)
    @fcm = FCM.new(StringIO.new(service_account), parsed_service_account["project_id"])
  end

  def send_notification(data:, topic:)
    data = JSON.parse(data) if data.is_a?(String)

    return { success: false, error: "The data must be a valid JSON object" } unless data.is_a?(Hash)
    return { success: false, error: "The topic must be present" } unless topic.present?

    send_to_topic(topic, data)
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
end
