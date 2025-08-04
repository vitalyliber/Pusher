class Api::NotificationsController < ApiAdminController
  def create
    result = mobile_access.send_notification(
      data: params[:payload].to_unsafe_h,
      topic: params[:topic],
      external_key: params[:external_key],
    )

    if result[:success]
      render json: { status: "success", response: result[:response] }, status: :ok
    else
      render json: { status: "error", error: result[:error] }, status: :unprocessable_entity
    end
  end
end
