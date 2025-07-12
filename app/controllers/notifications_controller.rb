class NotificationsController < ApplicationController
  def create
    service = FcmNotificationService.new(mobile_access.service_account)
    result = service.send_notification(notification_params)

    if result[:success]
      render json: { status: "success", response: result[:response] }, status: :ok
    else
      render json: { status: "error", error: result[:error] }, status: :unprocessable_entity
    end
  end

  private

  def notification_params
    params.expect(notification: [ :data, :topic, :external_key ])
  end
end
