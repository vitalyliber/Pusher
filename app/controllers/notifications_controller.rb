class NotificationsController < ApplicationController
  def index
  end

  def create
    service = FcmNotificationService.new(mobile_access.service_account)
    @result = service.send_notification(
      data: notification_params[:data],
      topic: notification_params[:topic],
      external_key: notification_params[:external_key]
    )
    render "index"
  end

  private

  def notification_params
    params.expect(notification: [ :data, :topic, :external_key ])
  end
end
