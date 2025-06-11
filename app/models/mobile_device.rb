class MobileDevice < ApplicationRecord
  belongs_to :mobile_user
  validates :device_token, :mobile_user, presence: true
  validates_uniqueness_of :device_token
end
