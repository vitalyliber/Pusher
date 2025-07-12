class RemoveMobileUserReferenceFromMobileDevices < ActiveRecord::Migration[8.0]
  def change
    remove_column :mobile_devices, :mobile_user_id, :bigint
  end
end
