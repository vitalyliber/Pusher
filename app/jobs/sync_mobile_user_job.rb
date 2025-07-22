class SyncMobileUserJob < ApplicationJob
  queue_as :default

  def perform(mobile_access_id, external_key)
    mobile_user = MobileUser.find_by(mobile_access_id:, external_key:)

    if mobile_user
      mobile_user.update_device_tokens_in_device_group
    else
      MobileUser.create(mobile_access_id:, external_key:)
    end
  end
end
