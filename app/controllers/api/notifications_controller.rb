class Api::NotificationsController < ApiAdminController
  def create
    result = mobile_access.send_notification(
      data: notification_params[:data],
      topic: notification_params[:topic],
      external_key: notification_params[:external_key],
    )

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
