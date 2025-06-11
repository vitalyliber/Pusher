class AddUserInfoAndDeviceInfoIntoMobileDevice < ActiveRecord::Migration[8.0]
  def change
    add_column :mobile_devices, :user_info, :string
    add_column :mobile_devices, :device_info, :string
    remove_column :mobile_devices, :device_type, :integer, default: 0
  end
end
