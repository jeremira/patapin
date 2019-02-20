class Agenda
  attr_reader :openings, :appointments, :slot_extent

  def initialize params = {}
    @openings     = params[:openings]      || []
    @appointments = params[:appointments]  || []
    @slot_extent  = params[:slot_extent]   || 30*60
  end

  def availabilities_for(date)
    {
      date: date,
      slots: slots_between(date.beginingoftheday, date.end_of_the day).select(&:available)
    }
  end

  #
  # Find all start time slots in a date range
  #
  def slots_between(starts_at, ends_at)
    (starts_at.to_i .. ends_at.to_i)
      .step(30.minutes)
      .map { |epoch| Time.at(epoch) }
  end

  #
  # Ensure a time slot has an opening and no appointment
  #
  def available?(datetime)
    opened?(datetime) && !booked?(datetime)
  end

  #
  # Ensure an appoitment is not already schedule at a specified datetime
  #
  def booked?(datetime)
    @appointments.find do |appointment|
      (datetime.between? appointment.starts_at, appointment.ends_at) ||
        (30.minutes.since(datetime).between? appointment.starts_at, appointment.ends_at)
    end
  end

  #
  # Ensure an opening exist at a specified datetime
  #
  def opened?(datetime)
    @openings.find do |opening|
      if opening.weekly_recurring
        start_time = Time.zone.parse(opening.starts_at.strftime("%Hh%Mm%Ss"))
        end_time = Time.zone.parse(opening.ends_at.strftime("%Hh%Mm%Ss"))
        ref_time = Time.zone.parse(datetime.strftime("%Hh%Mm%Ss"))
        # On same week day AND time included in range
        (opening.starts_at.wday == datetime.wday) &&
          (ref_time.between? start_time, end_time) &&
            (30.minutes.since(ref_time).between?(start_time, end_time))
      else
        (datetime.between?(opening.starts_at, opening.ends_at)) &&
          (30.minutes.since(datetime).between?(opening.starts_at, opening.ends_at))
      end
    end
  end
end
