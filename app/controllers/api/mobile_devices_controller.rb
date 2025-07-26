class Api::MobileDevicesController < ApiController
  def create
    mobile_device = MobileDevice.find_by(mobile_device_search_params)

    if mobile_device
      mobile_device.touch

      if mobile_device.external_key == mobile_device_full_params[:external_key]
        return render json: { mobile_device: }
      else
        # It means that the external key has changed, so we need to update it
        # This case can happen when the user re-registers with a different account
        # - Devs forgot to delete the old device token
        Rails.logger.info "Updating external key for existing mobile device: #{mobile_device.device_token}"
        if mobile_device.update(external_key: mobile_device_full_params[:external_key])
          process_mobile_user(mobile_device)

          return render render json: {  mobile_device: }
        else
          return render json: { errors: mobile_device.errors.full_messages }, status: 400
        end
      end
    end

    mobile_device = MobileDevice.new(mobile_device_full_params)

    return render(json: { errors: mobile_device.errors.full_messages }, status: 400) unless mobile_device.valid?

    if mobile_device.save
      process_mobile_user(mobile_device)

      render json: {}
    else
      render json: { errors: mobile_device.errors.full_messages }, status: 400
    end
  end

  def destroy
    mobile_device = MobileDevice.find_by(device_token: params[:id])

    mobile_device.mobile_user.remove_device_token_from_device_group([ mobile_device.device_token ])
    mobile_device.unsubscribe_from_topics
    mobile_device.delete

    render json: {}
  end

  def mobile_device_search_params
    params.expect(mobile_device: [ :device_token ])
  end

  def mobile_device_full_params
    params.expect(mobile_device: [ :device_token, :user_info, :device_info, :external_key ]).merge(mobile_access:)
  end

  def process_mobile_user(mobile_device)
    mobile_user = MobileUser.find_by(
      mobile_access:,
      external_key: mobile_device_full_params[:external_key]
    )

    if mobile_user
      mobile_user.update_device_tokens_in_device_group
    else
      mobile_user = MobileUser.create(
        mobile_access:,
        external_key: mobile_device_full_params[:external_key]
      )
      mobile_user.create_device_group_token
    end

    mobile_device.subscribe_to_topics
  end
end
