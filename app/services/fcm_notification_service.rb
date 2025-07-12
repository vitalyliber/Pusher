require "fcm"

class FcmNotificationService
  def initialize(service_account)
    service_account = JSON.parse(service_account) if service_account.is_a?(String)
    @fcm = FCM.new(service_account["private_key"], service_account)
  end

  def send_notification(data, topic, external_key)
    if topic
      send_to_topic(topic, data)
    else
      tokens = MobileDevice.where(external_key:).pluck(:device_token)
      send_to_devices(tokens, data)
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

  def send_to_devices(tokens, payload)
    response = @fcm.send(tokens, payload)
    Rails.logger.info "FCM notification sent to devices: #{response}"
    { success: true, response: response }
  end
end
