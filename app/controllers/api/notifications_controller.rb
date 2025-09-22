class Api::NotificationsController < ApiAdminController
  def create
    return render json: { errors: [ "The notification can be sent only on a topic or an external key, not both." ] }, status: :bad_request if params[:external_key].present? && params[:topic].present?

    @result = {}
    @result[:firebase] = if firebase_payload.present?
      mobile_access.send_notification(
        data: firebase_payload.to_unsafe_h,
        topic: params[:topic],
        external_key: params[:external_key],
      )
    else
      { error: "The firebase_payload is empty" }
    end
    @result[:huawei] = if params[:huawei_payload].present?
      mobile_access.huawei_notification_service.send_notification_by_external_key(
        payload: params[:huawei_payload].to_unsafe_h,
        topic: params[:topic],
        external_key: params[:external_key]
     )
    else
      { error: "The huawei_payload is empty" }
    end

    render json: { **@result }, status: :ok
  end

  private

  def firebase_payload
    params[:payload] || params[:firebase_payload]
  end
end
