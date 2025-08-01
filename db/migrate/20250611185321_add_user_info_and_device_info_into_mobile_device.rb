class AddUserInfoAndDeviceInfoIntoMobileDevice < ActiveRecord::Migration[8.0]
  def change
    add_column :mobile_devices, :user_info, :string
    add_column :mobile_devices, :device_info, :string
    add_column :mobile_devices, :external_key, :string
    add_index :mobile_devices, :external_key
    add_reference :mobile_devices, :mobile_access, foreign_key: true

    add_index :mobile_devices, [ :external_key, :device_token, :mobile_access_id ], unique: true, name: "index_mobile_devices_on_unique_combination"

    remove_column :mobile_devices, :device_type, :integer, default: 0
  end
end
