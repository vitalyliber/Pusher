class Api::MobileDevicesController < ApiClientController
  def create
    service = MobileDeviceService.new(
      params[:device_token],
      params[:user_info],
      params[:device_info],
      params[:external_key],
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
