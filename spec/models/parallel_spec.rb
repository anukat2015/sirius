require 'spec_helper'
require 'models/parallel'

describe Parallel do

  subject(:parallel) do
    parallel = Parallel.new
    allow(parallel).to receive(:timetable_slots).and_return(timetable_slots)
    parallel
  end

  # let(:schedule_params) { { first_hour: Time.parse('7:30'), hour_length: 45, break_length: 15, break_after: 2 } }
  # let(:converter) { Sirius::TimeConverter.new(schedule_params) }
  let(:period) { Period.parse('7:30', '9:00') }
  let(:converter) { instance_double(Sirius::TimeConverter, convert_time: period) }
  let(:event_planner) { instance_double(Sirius::EventPlanner, plan: [period]) }

  describe '#generate_events' do

    context 'when TimetableSlots are empty' do
      let(:timetable_slots) { [] }

      it 'outputs no events' do
        events = parallel.generate_events(converter, event_planner)
        expect(events).to eq([])
      end
    end

    context 'when TimetableSlots are not empty' do
      let(:timetable_slots) { [TimetableSlot.new(first_hour: 1, duration: 2, parity: :both, day: :monday)] }

      it 'converts Timetableslots to events' do
        events = parallel.generate_events(converter, event_planner)
        expect(events.size).to be > 0
        expect(events.first).to be_an_instance_of(Event)
      end
    end
  end

  describe '.from_kosapi' do
    let(:slots) { [] }
    let(:kosapi_parallel) { double(to_hash: {code: 1234, link: double(href: '432')}, timetable_slots: slots) }

    it 'converts kosapi parallel to sirius paralell entity' do
      parallel = Parallel.from_kosapi(kosapi_parallel)
      expect(parallel).to be_an_instance_of(Parallel)
      expect(parallel.code).to eq(1234)
    end

  end

end
