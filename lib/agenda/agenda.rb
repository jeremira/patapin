class Agenda
  attr_reader :openings, :appointments, :slot_extent

  def initialize params = {}
    @openings     = params[:openings]      || []
    @appointments = params[:appointments]  || []
    @slot_extent  = params[:slot_extent]   || 30*60
  end

#enforce slot extent

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
      date: date.strftime("%Y/%m/%d"),
      slots: available_slots_for(date)
    }
  end

  #
  # List properly formated available slots fot the day
  #
  def available_slots_for(date)
     slots_between(date.beginning_of_day, date.end_of_day)
      .select{ |time| available? time }
      .map   { |time| time.strftime("%H:%M") }
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
