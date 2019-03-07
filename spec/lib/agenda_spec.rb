require 'rails_helper'

RSpec.describe Agenda do
  let(:my_agenda) { Agenda.new(agenda_params) }
  let(:tested_date) {DateTime.parse("2014-08-10")}
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

  describe "#availabilities_from" do
    let(:on_test_function) {my_agenda.availabilities_from tested_date, days_spawn: spawn_delay}
    let(:stubbed_answer) {{"correct" => "date-slot"}}

    context "with invalid spawn" do
      let(:spawn_delay) {nil}

      it "return a list" do
        expect(on_test_function).to be_an Array
      end
      it "return an empty list" do
        expect(on_test_function).to eq []
      end
    end

    context "with a nul spawn" do
      let(:spawn_delay) {0}

      it "return a list" do
        expect(on_test_function).to be_an Array
      end
      it "return an empty list" do
        expect(on_test_function).to eq []
      end
    end

    context "with a 1 day spawn" do
      let(:spawn_delay) {1}

      before :each do
        expect(my_agenda).to receive(:availabilities_for).once.with(tested_date) {stubbed_answer}
      end

      it "return a list" do
        expect(on_test_function).to be_an Array
      end
      it "return a correct size list" do
        expect(on_test_function.size).to eq 1
      end
      it "return proper date element" do
        expect(on_test_function.first).to eq({"correct" => "date-slot"})
      end
    end

    context "with a 7 day spawn" do
      let(:spawn_delay) {7}
      before :each do
        expect(my_agenda).to receive(:availabilities_for).once.with(tested_date) {stubbed_answer}
        expect(my_agenda).to receive(:availabilities_for).once.with(tested_date + 1.day)   {stubbed_answer}
        expect(my_agenda).to receive(:availabilities_for).once.with(tested_date + 2.days)  {stubbed_answer}
        expect(my_agenda).to receive(:availabilities_for).once.with(tested_date + 3.days)  {stubbed_answer}
        expect(my_agenda).to receive(:availabilities_for).once.with(tested_date + 4.days)  {stubbed_answer}
        expect(my_agenda).to receive(:availabilities_for).once.with(tested_date + 5.days)  {stubbed_answer}
        expect(my_agenda).to receive(:availabilities_for).once.with(tested_date + 6.days)  {stubbed_answer}
      end

      it "return a list" do
        expect(on_test_function).to be_an Array
      end
      it "return a correct size list" do
        expect(on_test_function.size).to eq 7
      end
      it "return proper date element" do
        on_test_function.each { |elmt| expect(elmt).to eq({"correct" => "date-slot"}) }
      end
    end
  end

  describe "#availabilities_for" do
    let(:on_test_function) {my_agenda.availabilities_for tested_date}

    before :each do
      expect(my_agenda).to receive(:available_slots_for).with(tested_date) do
        ["babar", "bobor", "bibir"]
      end
    end

    it "return an hash" do
      expect(on_test_function).to be_an Hash
    end
    it "has a date key" do
      expect(on_test_function.has_key?(:date)).to be true
    end
    it "properly format date" do
      expect(on_test_function[:date]).to eq tested_date.to_date
    end
    it "has a slots key" do
      expect(on_test_function.has_key?(:slots)).to be true
    end
    it "include valid slots list" do
      expect(on_test_function[:slots]).to eq ["babar", "bobor", "bibir"]
    end
  end

  describe "#available_slots_for" do
    let(:on_test_function) {my_agenda.available_slots_for tested_date}

    context "with 0 availabilities" do
      before :each do
        allow(my_agenda).to receive(:available?) {false}
      end
      it "return an list" do
        expect(on_test_function).to be_an Array
      end
      it "setup an empty slot list" do
        expect(on_test_function).to eq []
      end
    end

    context "with all slot available" do
      before :each do
        allow(my_agenda).to receive(:available?) {true}
      end

      it "setup a slot list" do
        expect(on_test_function).to be_an Array
      end
      it "find all free slots" do
        expect(on_test_function.size).to eq 48
      end
      it "format correct slot" do
        expected_slot = (tested_date.beginning_of_day.to_i .. tested_date.end_of_day.to_i)
                            .step(30.minutes).map { |epoch| Time.at(epoch).utc.strftime("%-k:%M") }
        expect(on_test_function).to eq expected_slot
      end
    end

    context "with some slots available" do
      before :each do
        allow(my_agenda).to receive(:available?) {false}
        expect(my_agenda).to receive(:available?).with(Time.parse("2014-08-10 08:00:00 UTC")) {true}
        expect(my_agenda).to receive(:available?).with(Time.parse("2014-08-10 14:00:00 UTC")) {true}
        expect(my_agenda).to receive(:available?).with(Time.parse("2014-08-10 11:30:00 UTC")) {true}
      end

      it "setup a slot list" do
        expect(on_test_function).to be_an Array
      end
      it "find all free slots" do
        expect(on_test_function.size).to eq 3
      end
      it "format correct slot" do
        expect(on_test_function).to eq ["8:00", "11:30", "14:00"]
      end
    end
  end

  describe "#slots_between" do
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
    let(:on_test_function) {my_agenda.available? tested_date}

    context "with some openings" do
      before :each do
        allow(my_agenda).to receive(:opened?).with(tested_date) {true}
      end
      context "and no appointments" do
        before :each do
          allow(my_agenda).to receive(:booked?).with(tested_date) {false}
        end

        it "return true" do
          expect(on_test_function).to be true
        end
      end
      context "but some appointments" do
        before :each do
          allow(my_agenda).to receive(:booked?).with(tested_date) {true}
        end

        it "return false" do
          expect(on_test_function).to be false
        end
      end
    end
    context "with no openings" do
      before :each do
        allow(my_agenda).to receive(:opened?).with(tested_date) {false}
      end
      context "and no appointments" do
        before :each do
          allow(my_agenda).to receive(:booked?).with(tested_date) {false}
        end

        it "return false" do
          expect(on_test_function).to be false
        end
      end
      context "but some appointments" do
        before :each do
          allow(my_agenda).to receive(:booked?).with(tested_date) {true}
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
        let(:appointment) {create :event, :appointment, starts_at: 30.minutes.ago.to_datetime, ends_at: 1.second.ago.to_datetime}

        it "return nil" do
          expect(on_test_function).to be nil
        end
      end
      context "and finish on time" do
        let(:appointment) {create :event, :appointment, starts_at: 30.minutes.ago.to_datetime, ends_at: Time.zone.now.to_datetime}

        it "return nil" do
          expect(on_test_function).to be nil
        end
      end

      context "and finish in future" do
        let(:appointment) {create :event, :appointment, starts_at: 30.minutes.ago.to_datetime, ends_at: 10.minutes.since.to_datetime}

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
        let(:appointment) {create :event, :appointment, starts_at: Time.zone.now.to_datetime, ends_at: Time.zone.now.to_datetime}

        it "return nil" do
          expect(on_test_function).to be nil
        end
      end
      context "and finish in future" do
        let(:appointment) {create :event, :appointment, starts_at: Time.zone.now.to_datetime, ends_at: 30.minutes.since.to_datetime}

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
        let(:appointment) {create :event, :appointment, starts_at: (30*60+1).second.since.to_datetime, ends_at: 1.hour.since.to_datetime}

        it "return nil" do
          expect(on_test_function).to be nil
        end
      end

      context "appointment start in 30min" do
        let(:appointment) {create :event, :appointment, starts_at: (30*60).second.since.to_datetime, ends_at: 1.hour.since.to_datetime}

        it "return nil" do
          expect(on_test_function).to be nil
        end
      end

      context "appointment start in less than 30min" do
        let(:appointment) {create :event, :appointment, starts_at: (30*60-1).second.since.to_datetime, ends_at: 1.hour.since.to_datetime}

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
          let(:opening) {create :event, :opening, starts_at: 1.second.ago.to_datetime, ends_at: 29.minutes.since.to_datetime}

          it "return nil" do
            expect(on_test_function).to be nil
          end
        end
        context "and big enough spawn" do
          let(:opening) {create :event, :opening, starts_at: 1.second.ago.to_datetime, ends_at: (30*60+1).seconds.since.to_datetime}

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
          let(:opening) {create :event, :opening, starts_at: Time.zone.now.to_datetime, ends_at: (30*60).seconds.since.to_datetime}

          it "return nil" do
            expect(on_test_function).to be nil
          end
        end
        context "and big enough spawn" do
          let(:opening) {create :event, :opening, starts_at: Time.zone.now.to_datetime, ends_at: (30*60+1).seconds.since.to_datetime}

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
          let(:opening) {create :event, :opening, starts_at: 1.seconds.since.to_datetime, ends_at: (30*60).seconds.since.to_datetime}

          it "return nil" do
            expect(on_test_function).to be nil
          end
        end
        context "and big enough spawn" do
          let(:opening) {create :event, :opening, starts_at: 1.seconds.since.to_datetime, ends_at: (30*60+2).seconds.since.to_datetime}

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
          let(:opening) {create :event, :opening, weekly_recurring: true, starts_at: 1.second.ago.to_datetime, ends_at: 29.minutes.since.to_datetime}

          it "return nil" do
            expect(on_test_function).to be nil
          end
        end
        context "and big enough spawn" do
          let(:opening) {create :event, :opening, weekly_recurring: true, starts_at: 1.second.ago.to_datetime, ends_at: (30*60+1).seconds.since.to_datetime}

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
          let(:opening) {create :event, :opening, weekly_recurring: true, starts_at: Time.zone.now.to_datetime, ends_at: (30*60-1).seconds.since.to_datetime}

          it "return nil" do
            expect(on_test_function).to be nil
          end
        end
        context "and big enough spawn" do
          let(:opening) {create :event, :opening, weekly_recurring: true, starts_at: Time.zone.now.to_datetime, ends_at: (30*60+1).seconds.since.to_datetime}

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
          let(:opening) {create :event, :opening, weekly_recurring: true, starts_at: 1.seconds.since.to_datetime, ends_at: (30*60).seconds.since.to_datetime}

          it "return nil" do
            expect(on_test_function).to be nil
          end
        end
        context "and big enough spawn" do
          let(:opening) {create :event, :opening, weekly_recurring: true, starts_at: 1.seconds.since.to_datetime, ends_at: (30*60+2).seconds.since.to_datetime}

          it "return nil" do
            expect(on_test_function).to be nil
          end
        end
      end
    end

    context "acceptance check" do
      let(:on_time_opening) {create :event, :opening, starts_at: 1.hour.ago.to_datetime, ends_at: 1.hour.since.to_datetime}
      let(:past_opening)    {create :event, :opening, starts_at: 2.hour.ago.to_datetime, ends_at: 1.hour.ago.to_datetime}
      let(:futur_opening)   {create :event, :opening, starts_at: 1.hour.since.to_datetime, ends_at: 2.hour.since.to_datetime}
      let(:same_day_recurring) do
        create :event, :opening, weekly_recurring: true, starts_at: (7.days.ago - 1.hour).to_datetime, ends_at: (7.days.ago + 1.hour).to_datetime
      end
      let(:other_day_recurring) do
        create :event, :opening, weekly_recurring: true, starts_at: (2.days.ago - 1.hour).to_datetime, ends_at: (2.days.ago + 1.hour).to_datetime
      end
      let(:recurring_same_day_out_of_time) do
        create :event, :opening, weekly_recurring: true, starts_at: (7.days.ago + 1.hour).to_datetime, ends_at: (7.days.ago + 3.hour).to_datetime
      end
      let(:recurring_other_day_out_of_time) do
        create :event, :opening, weekly_recurring: true, starts_at: (4.days.ago + 1.hour).to_datetime, ends_at: (4.days.ago + 3.hour).to_datetime
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
