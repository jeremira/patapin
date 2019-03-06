require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:opening) {create :event, :opening}
  let(:appointment) {create :event, :appointment}

  describe "Factories" do
    it "has a valid apointment factory" do
      expect(appointment).to be_valid
    end
    it "has a valid opening factory" do
      expect(opening).to be_valid
    end
  end

  describe "Scopes" do
    describe ".openings" do
      let(:opening_scope) {Event.openings}

      context "when no events" do
        it "return an active record relation"  do
          expect(opening_scope).to eq []
        end
      end

      context "with no opening kind events" do
        before :each { create_list :event, 3, :appointment}

        it "return an active record relation"  do
          expect(opening_scope).to eq []
        end
      end
      context "with opening kind event" do
        before :each do
          create_list :event, 3, :opening
          create_list :event, 3, :appointment
        end

        it "return an active record relation"  do
          expect(opening_scope).to eq Event.where(kind: "opening")
        end
      end
    end
    describe ".appointments" do
      let(:appointment_scope) {Event.appointments}

      context "when no events" do
        it "return an active record relation"  do
          expect(appointment_scope).to eq []
        end
      end

      context "with no appointments kind events" do
        before :each { create_list :event, 3, :opening}

        it "return an active record relation"  do
          expect(appointment_scope).to eq []
        end
      end
      context "with appointments kind event" do
        before :each do
          create_list :event, 3, :opening
          create_list :event, 3, :appointment
        end

        it "return an active record relation"  do
          expect(appointment_scope).to eq Event.where(kind: "appointment")
        end
      end
    end
  end

  describe ".availabilities" do
    let(:tested_date) { DateTime.parse("2014-08-10") }
    let(:agenda_params) do
      {
        openings: Event.openings,
        appointments: Event.appointments
      }
    end
    let(:on_test_function) {Event.availabilities(tested_date)}

    before :each do
      expect(Agenda).to receive(:new).with(agenda_params) do
        instance_double("Agenda", availabilities_from: [{"available"=>"ok"}])
      end
    end

    it "return Agenda availabilities" do
      expect(on_test_function).to eq [{"available"=>"ok"}]
    end
  end
end
