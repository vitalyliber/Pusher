class RemoveDeviceTokenJob < ApplicationJob
  queue_as :default

  def perform(mobile_access_id, device_token, external_key)
    mobile_user = MobileUser.find_by(mobile_access_id:, external_key:)
    mobile_user.remove_device_token_from_device_group([ device_token ])
  end
end
