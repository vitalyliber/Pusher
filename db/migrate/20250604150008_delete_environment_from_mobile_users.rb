class DeleteEnvironmentFromMobileUsers < ActiveRecord::Migration[8.0]
  def change
    # Remove the 'environment' column from the 'mobile_users' table
    remove_column :mobile_users, :environment, :integer, default: 0

    MobileUser.select(:external_key, :mobile_access_id)
      .group(:external_key, :mobile_access_id)
      .having('COUNT(*) > 1')
      .each do |duplicate|
        MobileUser.where(external_key: duplicate.external_key, mobile_access_id: duplicate.mobile_access_id).offset(1).each do |user|
          user.mobile_devices.destroy_all
          user.destroy
        end
      end

    # Add back the unique index without the 'environment' column
    add_index :mobile_users, [ :external_key, :mobile_access_id ], unique: true, name: "index_mobile_users_on_external_key_and_mobile_access_id"
  end
end
