class DeleteMobileUserTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :mobile_users
  end
end
