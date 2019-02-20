require 'rails_helper'

RSpec.describe Agenda do
let(:my_agenda) { Agenda.new(agenda_params) }
  describe "#intialize" do

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
          expect(my_agenda.openings).to be_an Array
        end
        it "setup appointments with passed events" do
          expect(my_agenda.openings).to eq Event.appointments
        end
        it "expose slot extent" do
          expect(my_agenda.slot_extent).to be_an Integer
        end
        it "setup slot extent to a 30min delay" do
          expect(my_agenda.openings).to eq 35*60
        end
      end
    end
  end
end
