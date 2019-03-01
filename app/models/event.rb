class Event < ApplicationRecord

  # Scopes
  scope :openings,     ->() { where(kind: "opening") }
  scope :appointments, ->() { where(kind: "appointment") }

  def self.availabilities(date)
    Agenda.new(
      {
        openings: Event.openings,
        appointments: Event.appointments
      }
    ).availabilities_from(date, days_spawn: 7)
  end

end
