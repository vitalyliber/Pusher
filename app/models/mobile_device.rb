class MobileDevice < ApplicationRecord
  belongs_to :mobile_access
  validates :device_token, :external_key, :mobile_access, presence: true

  belongs_to :mobile_user, foreign_key: :external_key, primary_key: :external_key, optional: true
end
