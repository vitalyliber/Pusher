# app/services/mobile_device_service.rb
class MobileDeviceService
  attr_reader :device_token, :user_info, :device_info, :external_key, :mobile_access

  def initialize(device_token, user_info, device_info, external_key, mobile_access)
    @device_token = device_token
    @user_info = user_info
    @device_info = device_info
    @external_key = external_key
    @mobile_access = mobile_access
  end

  def create
    # return { json: { errors: [ "Device token can't be blank" ] }, status: :bad_request } if @device_token.blank?

    mobile_device = MobileDevice.find_by(device_token:)

    if mobile_device
      mobile_device.touch

      if mobile_device.external_key == external_key
        return { json: { mobile_device: }, status: 200 }
      else
        # It means that the external key has changed, so we need to update it
        # This case can happen when the user re-registers with a different account
        # - Devs forgot to delete the old device token
        Rails.logger.info "Updating external key for existing mobile device: #{mobile_device.device_token}"
        if mobile_device.update(external_key:)
          process_mobile_user(mobile_device)

          return { json: {  mobile_device: }, status: 200 }
        else
          return { json: { errors: mobile_device.errors.full_messages }, status: 400 }
        end
      end
    end

    mobile_device = MobileDevice.new(device_token:, user_info:, device_info:, external_key:, mobile_access:)

    return { json: { errors: mobile_device.errors.full_messages }, status: 400 } unless mobile_device.valid?

    if mobile_device.save
      process_mobile_user(mobile_device)

      { json: {} }
    else
      { json: { errors: mobile_device.errors.full_messages }, status: 400 }
    end
  end

  private

  def process_mobile_user(mobile_device)
    mobile_user = MobileUser.find_by(
      mobile_access:,
      external_key:
    )

    if mobile_user
      mobile_user.update_device_tokens_in_device_group
    else
      mobile_user = MobileUser.create(
        mobile_access:,
        external_key:
      )
      mobile_user.create_device_group_token
    end

    mobile_device.subscribe_to_topics
  end
end
