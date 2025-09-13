class AddPushProviderToMobileDevice < ActiveRecord::Migration[8.0]
  def change
    add_column :mobile_devices, :push_provider, :integer, default: 0
  end
end
