class RemoveRpushAppsTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :rpush_apps
  end
end
