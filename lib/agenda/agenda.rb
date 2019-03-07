class Agenda
  attr_reader :openings, :appointments, :slot_extent

  def initialize params = {}
    @openings     = params[:openings]      || []
    @appointments = params[:appointments]  || []
    @slot_extent  = params[:slot_extent]   || 30*60
  end

  #
  # List all slots available by date for a specified days spawn
  #
  def availabilities_from(date, days_spawn:)
    start_date = date.beginning_of_day.to_date
    end_date = (date.beginning_of_day + days_spawn.to_i.days).to_date
    (start_date...end_date).to_a.map { |date| availabilities_for date}
  end

  #
  # Format date and available slots in a hash format
  #
  def availabilities_for(date)
    {
      date: date.to_date,
      slots: available_slots_for(date)
    }
  end

  #
  # List properly formated available slots fot the day
  #
  def available_slots_for(date)
     slots_between(date.beginning_of_day, date.end_of_day)
      .select{ |time| available? time }
      .map   { |time| time.strftime("%-k:%M") }
  end

  #
  # Find all start time slots in a date range
  #
  def slots_between(starts_at, ends_at)
    (starts_at.to_i .. ends_at.to_i)
      .step(30.minutes)
      .map { |epoch| Time.at(epoch).utc }
  end

  #
  # Ensure a time slot has an opening and no appointment
  #
  def available?(datetime)
    !booked?(datetime) && opened?(datetime)
  end

  #
  # Ensure an appoitment is not already schedule at a specified datetime
  #
  def booked?(time)
    @appointments.find do |appointment|
      (appointment.starts_at ... appointment.ends_at).cover?(time) ||
        ((appointment.starts_at + 1) ... appointment.ends_at).cover?(30.minutes.since(time))
    end
  end

  #
  # Ensure an opening exist at a specified datetime
  #
  def opened?(time)
    @openings.find do |opening|
      if opening.weekly_recurring
        start_time = opening.starts_at.to_time.utc.strftime( "%H%M%S%N" )
        end_time = opening.ends_at.to_time.utc.strftime( "%H%M%S%N" )
        slot_start = time.utc.strftime("%H%M%S%N")
        slot_end = 30.minutes.since(time).utc.strftime("%H%M%S%N")
        # On same week day AND time included in range
        (opening.starts_at.wday == time.wday) &&
          (start_time .. end_time).cover?(slot_start) &&
            (start_time .. end_time).cover?(slot_end)

      #     (ref_time.between? start_time, end_time) &&
      #       (30.minutes.since(ref_time).between?(start_time, end_time))
      else
        (time.between?(opening.starts_at, opening.ends_at)) &&
          (30.minutes.since(time).between?(opening.starts_at, opening.ends_at))
      end
    end
  end
end
