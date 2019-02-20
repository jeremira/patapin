class Agenda
  attr_reader :openings, :appointments, :slot_extent

  def initialize params = {}
    @openings     = params[:openings]      || []
    @appointments = params[:appointments]  || []
    @slot_extent  = params[:slot_extent]   || 30*60
  end
  
end
