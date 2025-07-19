class AddProjectIdAndJsonKeyToMobileAccess < ActiveRecord::Migration[8.0]
  def change
    add_column :mobile_accesses, :fcm_json_key, :text
    add_column :mobile_accesses, :fcm_project_id, :string
  end
end
