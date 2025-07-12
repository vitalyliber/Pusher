class MobileDevicesController < ApplicationController
  def create
    mobile_device = MobileDevice.find_by(mobile_device_search_params)

    return render json: {
      mobile_device: mobile_device
    } if mobile_device

    mobile_device = MobileDevice.new(mobile_device_full_params)

    return render(json: { errors: mobile_device.errors.full_messages }, status: 400) unless mobile_device.valid?

    if mobile_device.save
      render json: {}
    else
      render json: { errors: mobile_device.errors.full_messages }, status: 400
    end
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
    params.expect(mobile_device: [ :device_token, :user_info, :device_info, :external_key ]).merge(mobile_access: current_app)
  end
end
