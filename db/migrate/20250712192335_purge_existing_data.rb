class PurgeExistingData < ActiveRecord::Migration[8.0]
  def change
    MobileDevice.delete_all
  end
end
