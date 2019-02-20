class Agenda
  attr_reader :openings, :appointments, :slot_extent

  def initialize params = {}
    @openings     = params[:openings]      || []
    @appointments = params[:appointments]  || []
    @slot_extent  = params[:slot_extent]   || 30*60
  end

  #
  # Ensure an opening exist at a specified datetime
  #
  def opened?(datetime)
    #@openings.find { |opening| opening.day == date.day &&&&&&  opening.start_at..opening.end_at == date}
    @openings.find do |opening|
      datetime.between? opening.starts_at, opening.ends_at
    end
  end
end
