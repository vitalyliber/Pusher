class MobileAccess < ApplicationRecord
  before_create :generate_server_token
  before_create :generate_client_token
  validates_presence_of :app_name
  validates_uniqueness_of :app_name

  delegate :get_instance_id_info, to: :notification_service

  has_many :mobile_devices

  def send_notification(data:, topic: nil, external_key: nil)
    notification_service.send_notification(
      data:,
      topic:,
      external_key:,
    )
  end

  def notification_service
    @_notification_service ||= FcmNotificationService.new(fcm_json_key, fcm_project_id)
  end

  private

  def generate_server_token
    self.server_token = SecureRandom.urlsafe_base64
    generate_server_token if MobileAccess.exists?(server_token: self.server_token)
  end

  def generate_client_token
    self.client_token = SecureRandom.urlsafe_base64
    generate_client_token if MobileAccess.exists?(client_token: self.client_token)
  end
end
