class RpushApp < ApplicationRecord
   self.inheritance_column = nil

  scope :by_name, ->(name) { where(name: name) }
  scope :last_by_name, ->(name) { by_name(name).last }
end
