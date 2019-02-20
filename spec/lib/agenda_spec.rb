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

  describe "#availabilities_for" do

    todo HERE
  end

  describe "#slots_between" do
    # creer array de start at everu 30min
    let(:on_test_function) {my_agenda.slots_between starting, ending}

    context "when time continium is preserved" do
      let(:starting) {DateTime.parse("Wed, 13 Feb 2019 10:00:00 UTC +00:00")}
      let(:ending) {DateTime.parse("Wed, 13 Feb 2019 11:30:00 UTC +00:00")}

      it "return an Array" do
        expect(on_test_function).to be_an Array
      end
      it "find all valid slot" do
        expect(on_test_function.size).to eq 4
      end
      it "find goot slot start time" do
        expect(on_test_function).to eq [
          DateTime.parse("Wed, 13 Feb 2019 10:00:00 UTC +00:00"),
          DateTime.parse("Wed, 13 Feb 2019 10:30:00 UTC +00:00"),
          DateTime.parse("Wed, 13 Feb 2019 11:00:00 UTC +00:00"),
          DateTime.parse("Wed, 13 Feb 2019 11:30:00 UTC +00:00")
        ]
      end
    end

    context "when time continium is fucked up" do
      let(:starting) {DateTime.parse("11h30m00")}
      let(:ending) {DateTime.parse("10h00m00")}

      it "return an Array" do
        expect(on_test_function).to be_an Array
      end
      it "return an empty array" do
        expect(on_test_function).to eq []
      end
    end
  end

  describe "#available?" do
    let(:on_test_function) {my_agenda.available? Time.zone.now}

    context "with some openings" do
      before :each do
        allow(my_agenda).to receive(:opened?).with(Time.zone.now) {true}
      end
      context "and no appointments" do
        before :each do
          allow(my_agenda).to receive(:booked?).with(Time.zone.now) {false}
        end

        it "return true" do
          expect(on_test_function).to be true
        end
      end
      context "but some appointments" do
        before :each do
          allow(my_agenda).to receive(:booked?).with(Time.zone.now) {true}
        end

        it "return false" do
          expect(on_test_function).to be false
        end
      end
    end
    context "with no openings" do
      before :each do
        allow(my_agenda).to receive(:opened?).with(Time.zone.now) {false}
      end
      context "and no appointments" do
        before :each do
          allow(my_agenda).to receive(:booked?).with(Time.zone.now) {false}
        end

        it "return false" do
          expect(on_test_function).to be false
        end
      end
      context "but some appointments" do
        before :each do
          allow(my_agenda).to receive(:booked?).with(Time.zone.now) {true}
        end

        it "return false" do
          expect(on_test_function).to be false
        end
      end
    end
  end

  describe "#booked?" do
    let(:on_test_function) {my_agenda.booked? Time.zone.now}

    before :each do
      appointment
    end

    context "appointment start in past" do
      context "and finish in past" do
        let(:appointment) {create :event, :appointment, starts_at: 2.second.ago, ends_at: 1.second.ago}

        it "return nil" do
          expect(on_test_function).to be nil
        end
      end
      context "and finish on time" do
        let(:appointment) {create :event, :appointment, starts_at: 1.second.ago, ends_at: Time.zone.now}

        it "return nil" do
          expect(on_test_function).to be nil
        end
      end

      context "and finish in future" do
        let(:appointment) {create :event, :appointment, starts_at: 1.second.ago, ends_at: 1.second.since}

        it "return an Event" do
          expect(on_test_function).to be_an Event
        end
        it "return an valid appointment" do
          expect(on_test_function).to eq appointment
        end
      end
    end

    context "appointment start on time" do
      context "and finish on time" do
        let(:appointment) {create :event, :appointment, starts_at: Time.zone.now, ends_at: Time.zone.now}

        it "return nil" do
          expect(on_test_function).to be nil
        end
      end
      context "and finish in future" do
        let(:appointment) {create :event, :appointment, starts_at: Time.zone.now, ends_at: 1.second.since}

        it "return an Event" do
          expect(on_test_function).to be_an Event
        end
        it "return an valid appointment" do
          expect(on_test_function).to eq appointment
        end
      end
    end

    context "appointment start in futur" do

      context "appointment start in more than 30min" do
        let(:appointment) {create :event, :appointment, starts_at: (30*60+1).second.since, ends_at: 1.hour.since}

        it "return nil" do
          expect(on_test_function).to be nil
        end
      end

      context "appointment start in 30min" do
        let(:appointment) {create :event, :appointment, starts_at: (30*60).second.since, ends_at: 1.hour.since}

        it "return an Event" do
          expect(on_test_function).to be_an Event
        end
        it "return an valid appointment" do
          expect(on_test_function).to eq appointment
        end
      end

      context "appointment start in less than 30min" do
        let(:appointment) {create :event, :appointment, starts_at: (30*60-1).second.since, ends_at: 1.hour.since}

        it "return an Event" do
          expect(on_test_function).to be_an Event
        end
        it "return an valid appointment" do
          expect(on_test_function).to eq appointment
        end
      end
    end
  end

  describe "#opened?" do
    let(:on_test_function)  {my_agenda.opened? Time.zone.now}

    context "non-recurring opening" do
      before :each do
        opening
      end

      context "starting in the past" do
        context "and not big enough spawn" do
          let(:opening) {create :event, :opening, starts_at: 1.second.ago, ends_at: 29.minutes.since}

          it "return nil" do
            expect(on_test_function).to be nil
          end
        end
        context "and big enough spawn" do
          let(:opening) {create :event, :opening, starts_at: 1.second.ago,   ends_at: (30*60+1).seconds.since}

          it "return an Event" do
            expect(on_test_function).to be_an Event
          end
          it "return an valid opening" do
            expect(on_test_function).to eq opening
          end
        end
      end

      context "starting on the spot" do
        context "and not big enough spawn" do
          let(:opening) {create :event, :opening, starts_at: Time.zone.now, ends_at: (30*60).seconds.since}

          it "return nil" do
            expect(on_test_function).to be nil
          end
        end
        context "and big enough spawn" do
          let(:opening) {create :event, :opening, starts_at: Time.zone.now, ends_at: (30*60+1).seconds.since}

          it "return an Event" do
            expect(on_test_function).to be_an Event
          end
          it "return an valid opening" do
            expect(on_test_function).to eq opening
          end
        end
      end

      context "starting in the future" do
        context "and not big enough spawn" do
          let(:opening) {create :event, :opening, starts_at: 1.seconds.since, ends_at: (30*60).seconds.since}

          it "return nil" do
            expect(on_test_function).to be nil
          end
        end
        context "and big enough spawn" do
          let(:opening) {create :event, :opening, starts_at: 1.seconds.since, ends_at: (30*60+2).seconds.since}

          it "return nil" do
            expect(on_test_function).to be nil
          end
        end
      end
    end

    context "recurring opening" do
      before :each do
        opening
      end

      context "starting in the past" do
        context "and not big enough spawn" do
          let(:opening) {create :event, :opening, weekly_recurring: true, starts_at: 1.second.ago, ends_at: 29.minutes.since}

          it "return nil" do
            expect(on_test_function).to be nil
          end
        end
        context "and big enough spawn" do
          let(:opening) {create :event, :opening, weekly_recurring: true, starts_at: 1.second.ago,   ends_at: (30*60+1).seconds.since}

          it "return an Event" do
            expect(on_test_function).to be_an Event
          end
          it "return an valid opening" do
            expect(on_test_function).to eq opening
          end
        end
      end

      context "starting on the spot" do
        context "and not big enough spawn" do
          let(:opening) {create :event, :opening, weekly_recurring: true, starts_at: Time.zone.now, ends_at: (30*60-1).seconds.since}

          it "return nil" do
            expect(on_test_function).to be nil
          end
        end
        context "and big enough spawn" do
          let(:opening) {create :event, :opening, weekly_recurring: true, starts_at: Time.zone.now, ends_at: (30*60+1).seconds.since}

          it "return an Event" do
            expect(on_test_function).to be_an Event
          end
          it "return an valid opening" do
            expect(on_test_function).to eq opening
          end
        end
      end

      context "starting in the future" do
        context "and not big enough spawn" do
          let(:opening) {create :event, :opening, weekly_recurring: true, starts_at: 1.seconds.since, ends_at: (30*60).seconds.since}

          it "return nil" do
            expect(on_test_function).to be nil
          end
        end
        context "and big enough spawn" do
          let(:opening) {create :event, :opening, weekly_recurring: true, starts_at: 1.seconds.since, ends_at: (30*60+2).seconds.since}

          it "return nil" do
            expect(on_test_function).to be nil
          end
        end
      end
    end

    context "acceptance check" do
      let(:on_time_opening) {create :event, :opening, starts_at: 1.hour.ago,   ends_at: 1.hour.since}
      let(:past_opening)    {create :event, :opening, starts_at: 2.hour.ago,   ends_at: 1.hour.ago}
      let(:futur_opening)   {create :event, :opening, starts_at: 1.hour.since, ends_at: 2.hour.since}
      let(:same_day_recurring) do
        create :event, :opening, weekly_recurring: true, starts_at: (7.days.ago - 1.hour), ends_at: (7.days.ago + 1.hour)
      end
      let(:other_day_recurring) do
        create :event, :opening, weekly_recurring: true, starts_at: (2.days.ago - 1.hour), ends_at: (2.days.ago + 1.hour)
      end
      let(:recurring_same_day_out_of_time) do
        create :event, :opening, weekly_recurring: true, starts_at: (7.days.ago + 1.hour), ends_at: (7.days.ago + 3.hour)
      end
      let(:recurring_other_day_out_of_time) do
        create :event, :opening, weekly_recurring: true, starts_at: (4.days.ago + 1.hour), ends_at: (4.days.ago + 3.hour)
      end

      context "when no openings exist" do
        it "return nil" do
          expect(on_test_function).to be nil
        end
      end

      context "when no openings match the requested date" do
        before :each do
          past_opening
          futur_opening
          other_day_recurring
          recurring_same_day_out_of_time
          recurring_other_day_out_of_time
        end
        it "return nil" do
          expect(on_test_function).to be nil
        end
      end

      context "when an opening match the requested date" do
        before :each do
          past_opening
          futur_opening
          other_day_recurring
          on_time_opening
          recurring_same_day_out_of_time
          recurring_other_day_out_of_time
        end
        it "return an Event" do
          expect(on_test_function).to be_an Event
        end
        it "return an valid opening" do
          expect(on_test_function).to eq on_time_opening
        end
      end

      context "when a reccuring opening match the requested date" do
        before :each do
          past_opening
          futur_opening
          other_day_recurring
          same_day_recurring
          recurring_same_day_out_of_time
          recurring_other_day_out_of_time
        end
        it "return an Event" do
          expect(on_test_function).to be_an Event
        end
        it "return an valid opening" do
          expect(on_test_function).to eq same_day_recurring
        end
      end

      context "when different opening match the requested date" do
        before :each do
          past_opening
          futur_opening
          other_day_recurring
          on_time_opening
          same_day_recurring
          recurring_same_day_out_of_time
          recurring_other_day_out_of_time
        end
        it "return an Event" do
          expect(on_test_function).to be_an Event
        end
        it "return an valid opening" do
          expect([on_time_opening, same_day_recurring]).to include(on_test_function)
        end
      end
    end
  end
end
