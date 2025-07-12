class AttachMobileAccessToAllMobileDevices < ActiveRecord::Migration[8.0]
  def change
    MobileDevice.includes(mobile_user: :mobile_access).find_in_batches do |batch|
      updates = []
      batch.each do |device|
        if device.mobile_user
          updates << {
            id: device.id,
            mobile_access_id: device.mobile_user.mobile_access_id,
            external_key: device.mobile_user.external_key
          }
        end
      end
      p "Updating mobile devices with mobile access association: #{updates.size} devices"
      MobileDevice.upsert_all(updates, unique_by: :id)
    end
  end
end
