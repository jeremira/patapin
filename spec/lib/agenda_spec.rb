require 'rails_helper'

RSpec.describe Agenda do
  let(:my_agenda) { Agenda.new(agenda_params) }
  let(:agenda_params) do
    {
      openings: Event.openings,
      appointments: Event.appointments
    }
  end

  before :each do
    freezed_time = Time.zone.now
    allow(Time.zone).to receive(:now) {freezed_time}
  end

  describe "#initialize" do

    it "instanciate" do
      expect(Agenda.new).to be_an Agenda
    end

    context "by default" do
      let(:my_agenda) { Agenda.new }

      it "expose openings" do
        expect(my_agenda.openings).to be_an Array
      end
      it "setup openings as an empty Array" do
        expect(my_agenda.openings).to eq []
      end
      it "expose appointments" do
        expect(my_agenda.openings).to be_an Array
      end
      it "setup appointments as an empty Array" do
        expect(my_agenda.openings).to eq []
      end
      it "expose slot extent" do
        expect(my_agenda.slot_extent).to be_an Integer
      end
      it "setup slot extent to a 30min delay" do
        expect(my_agenda.slot_extent).to eq 30*60
      end
    end
    context "with params" do
      let(:agenda_params) do
        {
          openings: create_list(:event, 3, :opening),
          appointments: create_list(:event, 3, :appointment),
          slot_extent: 35*60
        }
      end

      it "expose openings" do
        expect(my_agenda.openings).to be_an Array
      end
      it "setup openings with passed events" do
        expect(my_agenda.openings).to eq Event.openings
      end
      it "expose appointments" do
        expect(my_agenda.appointments).to be_an Array
      end
      it "setup appointments with passed events" do
        expect(my_agenda.appointments).to eq Event.appointments
      end
      it "expose slot extent" do
        expect(my_agenda.slot_extent).to be_an Integer
      end
      it "setup slot extent to a 30min delay" do
        expect(my_agenda.slot_extent).to eq 35*60
      end
    end
  end

  describe "#opened?" do

    context "with recurring event" do
    end

    context "with no recurring events" do
      let(:on_time_opening) {create :event, :opening, starts_at: 1.hour.ago,   ends_at: 1.hour.since}
      let(:past_opening)    {create :event, :opening, starts_at: 2.hour.ago,   ends_at: 1.hour.ago}
      let(:futur_opening)   {create :event, :opening, starts_at: 1.hour.since, ends_at: 2.hour.since}
      let(:on_test_function)  {my_agenda.opened? Time.zone.now}

      context "when no openings exist" do
        it "return nil" do
          expect(on_test_function).to be nil
        end
      end

      context "when no openings match the requested date" do
        before :each do
          past_opening
          futur_opening
        end
        it "return nil" do
          expect(on_test_function).to be nil
        end
      end

      context "when an opening match the requested date" do
        before :each do
          past_opening
          futur_opening
          on_time_opening
        end
        it "return an Event" do
          expect(on_test_function).to be_an Event
        end
        it "return an valid opening" do
          expect(on_test_function).to eq on_time_opening
        end
      end
    end

  end
end
