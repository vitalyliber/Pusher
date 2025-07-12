class MobileDevice < ApplicationRecord
  belongs_to :mobile_access
  validates :device_token, :external_key, :mobile_access, presence: true
end
