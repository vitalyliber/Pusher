require "fcm"

class FcmNotificationService
  def initialize(service_account, project_id)
    @project_id = project_id
    parsed_service_account = JSON.parse(service_account) if service_account.is_a?(String)
    @fcm = FCM.new(StringIO.new(service_account), parsed_service_account["project_id"])
  end

  def recover_notification_key(external_key)
    response = @fcm.recover_notification_key(external_key, @project_id)
    Rails.logger.info "Recovering notification key for external_key: #{external_key}, response: #{response}"
    if response[:response] == "success"
      JSON.parse(response[:body])["notification_key"]
    end
  end

  def create_notification_key(external_key, registration_ids)
    response = @fcm.create(external_key, @project_id, registration_ids)
    Rails.logger.info "Creating notification key for external_key: #{external_key}, response: #{response}"
    body = JSON.parse(response[:body])
    return recover_notification_key(external_key) if body["error"] == "notification_key already exists"
    if response[:response] == "success"
      body["notification_key"]
    end
  end

  def add(external_key, notification_key, registration_ids)
    response = @fcm.add(external_key, @project_id, notification_key, registration_ids)
    Rails.logger.info "Adding registration_ids for external_key: #{external_key}, response: #{response}"
    body = JSON.parse(response[:body])
    if body["error"] == "notification_key not found" || body["error"]&.include?("Secure token does not match")
      { notification_key: create_notification_key(external_key, registration_ids) }
    end
  end

  def remove(external_key, notification_key, registration_ids)
    response = @fcm.remove(external_key, @project_id, notification_key, registration_ids)
    Rails.logger.info response
  end

  def send_notification(data:, topic: nil, external_key: nil)
    token = nil
    if external_key.present?
      token = MobileUser.find_by(external_key:).device_group_token
    end
    data = JSON.parse(data) if data.is_a?(String)
    data = { **data, topic:, token: }.reject { |key, value| value.blank? }
    Rails.logger.info "Sending FCM notification with data: #{data}, topic: #{topic}, external_key: #{external_key}"

    return { success: false, error: "The data must be a valid JSON object" } unless data.is_a?(Hash)
    send(data)
  rescue StandardError => e
    Rails.logger.error "Error sending FCM notification: #{e.message}"
    { success: false, error: e.message }
  end

  def batch_topic_subscription(topic, registration_tokens)
    @fcm.batch_topic_subscription(topic, registration_tokens)
  end

  def batch_topic_subscription(topic, registration_tokens)
    @fcm.batch_topic_subscription(topic, registration_tokens)
  end

  private

  def send(data)
    response = @fcm.send_v1(data)
    Rails.logger.info "FCM notification sent to topic: #{response}"
    { success: true, response: response }
  end
end
