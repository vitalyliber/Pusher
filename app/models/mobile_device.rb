class MobileDevice < ApplicationRecord
  include PgSearch::Model

  enum :push_provider, [ :firebase, :huawei ]

  belongs_to :mobile_access
  validates :device_token, :external_key, :mobile_access, presence: true

  belongs_to :mobile_user, foreign_key: :external_key, primary_key: :external_key, optional: true

  pg_search_scope :search_by_info,
                  against: [ :device_info, :user_info ],
                  using: {
                    tsearch: { prefix: true, dictionary: "english" }
                  }
end
