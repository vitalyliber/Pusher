class MobileAccess < ApplicationRecord
  before_create :generate_server_token
  before_create :generate_client_token
  validates_presence_of :app_name
  validates_uniqueness_of :app_name

  def send_notification(data:, topic:)
    notification_service.send_notification(
      data: data,
      topic: topic,
    )
  end

  private

  def notification_service
    FcmNotificationService.new(service_account)
  end

  def service_account
    RpushApp.where(name: app_name).try(:last).try(:json_key)
  end

  def generate_server_token
    self.server_token = SecureRandom.urlsafe_base64
    generate_server_token if MobileAccess.exists?(server_token: self.server_token)
  end

  def generate_client_token
    self.client_token = SecureRandom.urlsafe_base64
    generate_client_token if MobileAccess.exists?(client_token: self.client_token)
  end
end
