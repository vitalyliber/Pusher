class RemoveOutdatedTables < ActiveRecord::Migration[8.0]
  def change
    drop_table :rpush_notifications
    drop_table :rpush_feedback
  end
end
