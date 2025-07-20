class MobileUser < ApplicationRecord
  belongs_to :mobile_access, optional: true

  validates :device_group_token, presence: true
  validates :external_key, presence: true, uniqueness: { scope: [ :device_group_token, :mobile_access_id ] }
  validates :topics, presence: true

  has_many :mobile_devices, foreign_key: :external_key, primary_key: :external_key
end
