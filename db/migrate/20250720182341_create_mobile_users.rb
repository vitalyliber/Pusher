class CreateMobileUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :mobile_users do |t|
      t.text :device_group_token, default: nil
      t.text :topics, array: true, default: [ "general" ]
      t.string :external_key, default: ""
      t.references :mobile_access, foreign_key: true

      t.timestamps
    end

    add_index :mobile_users, [ :external_key, :mobile_access_id ], unique: true, name: "index_mobile_users_on_unique_combination"
  end
end
