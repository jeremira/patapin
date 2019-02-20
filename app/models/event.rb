class Event < ApplicationRecord

  # Scopes
  scope :openings,     ->() { where(kind: "opening") }
  scope :appointments, ->() { where(kind: "appointment") }

end
