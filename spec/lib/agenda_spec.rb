require 'rails_helper'

RSpec.describe Agenda do
:openings, :appointments, :slot_extent,
let(:my_agenda) { Agenda.new(agenda_params) }
  describe "#intialize" do


    it "instanciate" do
      expect(Agenda.new).to be_an Agenda
    end

    context "by default" do
      let(:agenda_params) {}
      it "expose openings" do
        expext(my_agenda.openings).to be_an Array
      end
      it "setup openings as an empty Array" do
        expext(my_agenda.openings).to eq []
      end
      it "expose appointments" do
        expext(my_agenda.openings).to be_an Array
      end
      it "setup appointments as an empty Array" do
        expext(my_agenda.openings).to eq []
      end
      it "expose slot extent" do
        expext(my_agenda.slot_extent).to be_an Integer
      end
      it "setup slot extent to a 30min delay" do
        expext(my_agenda.openings).to eq 30*60
      end

      context "with params" do
        let(:agenda_params) do
          openings: ,
          appointments: ,
          slot_extent: 35*60
        end
        it "expose openings" do
          expext(my_agenda.openings).to be_an Array
        end
        it "setup openings as an empty Array" do
          expext(my_agenda.openings).to eq []
        end
        it "expose appointments" do
          expext(my_agenda.openings).to be_an Array
        end
        it "setup appointments as an empty Array" do
          expext(my_agenda.openings).to eq []
        end
        it "expose slot extent" do
          expext(my_agenda.slot_extent).to be_an Integer
        end
        it "setup slot extent to a 30min delay" do
          expext(my_agenda.openings).to eq 30*60
        end
      end
    end


  end
end
