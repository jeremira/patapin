require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:opening) {create :event, :opening}
  let(:appointment) {create :event, :appointment}

  describe "factories" do
    it "has a valid apointment factory" do
      expect(appointment).to be_valid
    end
    it "has a valid opening factory" do
      expect(opening).to be_valid
    end
  end
end
