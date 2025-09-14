class Api::MobileDevicesController < ApiClientController
  def create
    result = nil

    if params[:push_provider] == "huawei"
      service = HuaweiMobileDeviceService.new(
        params[:device_token],
        params[:user_info],
        params[:device_info],
        params[:external_key],
        mobile_access
      )
      result = service.create
    else
      service = MobileDeviceService.new(
        params[:device_token],
        params[:user_info],
        params[:device_info],
        params[:external_key],
        mobile_access
      )
      result = service.create
    end

    render json: result[:json], status: result[:status]
  end

  def destroy
    mobile_device = mobile_access.mobile_devices.where(device_token: params[:id]).first

    return render json: { errors: [ "Mobile device not found" ] }, status: :not_found unless mobile_device

    mobile_device.mobile_user.remove_device_token_from_device_group([ mobile_device.device_token ])
    unsubscribe_from_topics(mobile_device)
    mobile_device.delete
    mobile_access.subscribe_to_basic_topics(params[:id])

    render json: {}
  end

  private

  def unsubscribe_from_topics(mobile_device)
    device_token = mobile_device.device_token
    mobile_device.mobile_user.topics.each do |topic|
      Rails.logger.info "Unsubscribing from topic: #{topic} with device token: #{device_token}"

      mobile_access.notification_service.batch_topic_unsubscription(topic, [ device_token ]) if mobile_device.firebase?
      # @TODO unsubscribe from topics if mobile_device.huawei?
    end
  end
end
