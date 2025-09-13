class AddHuaweiCredentialsToMobileAccess < ActiveRecord::Migration[8.0]
  def change
    add_column :mobile_accesses, :huawei_client_id, :string
    add_column :mobile_accesses, :huawei_client_secret, :string
  end
end
