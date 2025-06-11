class MobileDevicesController < ApplicationController
  def create
    mobile_device = MobileDevice.find_by(mobile_device_params)

    return render json: {
      mobile_device: mobile_device,
      mobile_user: mobile_device.mobile_user
    } if mobile_device

    mobile_user = MobileUser.find_or_create_by(mobile_user_params)

    return render(json: { errors: mobile_user.errors.full_messages }, status: 400) unless mobile_user.valid?

    mobile_device = MobileDevice.new(mobile_device_full_params.merge(mobile_user:))

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

  def mobile_device_params
    params.expect(mobile_device: [ :device_token ])
  end

  def mobile_device_full_params
    params.expect(mobile_device: [ :device_token, :user_info, :device_info ])
  end

  def mobile_user_params
    params.expect(mobile_user: [ :external_key ])
          .merge(mobile_access: current_app)
  end
end
