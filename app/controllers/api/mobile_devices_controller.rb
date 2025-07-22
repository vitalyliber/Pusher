class Api::MobileDevicesController < ApiController
  def create
    mobile_device = MobileDevice.find_by(mobile_device_search_params)

    if mobile_device
      mobile_device.touch

      return render json: {
        mobile_device: mobile_device
      }
    end

    mobile_device = MobileDevice.new(mobile_device_full_params)

    return render(json: { errors: mobile_device.errors.full_messages }, status: 400) unless mobile_device.valid?

    if mobile_device.save
      render json: {}
    else
      render json: { errors: mobile_device.errors.full_messages }, status: 400
    end

    SyncMobileUserJob.perform_later(mobile_access.id, mobile_device_full_params[:external_key])
  end

  def destroy
    MobileDevice
        .find_by(device_token: params[:id])
        .try(:delete)
    render json: {}
  end

  def mobile_device_search_params
    params.expect(mobile_device: [ :device_token ])
  end

  def mobile_device_full_params
    params.expect(mobile_device: [ :device_token, :user_info, :device_info, :external_key ]).merge(mobile_access:)
  end
end
