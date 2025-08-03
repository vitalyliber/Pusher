class Api::MobileDevicesController < ApiClientController
  def create
    permitted_params = params.expect(mobile_device: [ :device_token, :user_info, :device_info, :external_key ])

    service = MobileDeviceService.new(
      permitted_params[:device_token],
      permitted_params[:user_info],
      permitted_params[:device_info],
      permitted_params[:external_key],
      mobile_access
    )
    result = service.create
    render json: result[:json], status: result[:status]
  end

  def destroy
    mobile_device = mobile_access.mobile_devices.where(device_token: params[:id]).first

    return render json: { errors: [ "Mobile device not found" ] }, status: :not_found unless mobile_device

    mobile_device.mobile_user.remove_device_token_from_device_group([ mobile_device.device_token ])
    mobile_device.unsubscribe_from_topics
    mobile_device.delete
    mobile_access.subscribe_to_basic_topics(params[:id])

    render json: {}
  end
end
