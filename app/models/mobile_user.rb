class MobileUser < ApplicationRecord
  validates :external_key, :mobile_access, presence: true
  validates_uniqueness_of :external_key, scope: %i[mobile_access]
  has_many :mobile_devices
  belongs_to :mobile_access
end
