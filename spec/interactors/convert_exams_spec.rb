require 'spec_helper'
require 'interactors/convert_exams'

describe ConvertExams do

  subject { described_class }
  let(:course) { double(link_id: 'BI-ZUM', link_title: 'Sample course') }
  let(:room) { double(link_id: 'T9:105') }
  let(:teacher) { double(link_id: 'kordikp', link_title: 'Ing. Pavel Kordík Ph.D.') }
  let(:exam) { double(:exam, link: double(link_id: 620283180005), start_date: Time.parse('2015-01-12T11:00:00'), end_date: Time.parse('2015-01-12T12:00:00'),
                      capacity: 10, course: course, room: room, examiner: teacher, term_type: :final_exam)}
  let(:exams) { [exam] }
  let(:faculty_semester) { Fabricate.build(:faculty_semester) }

  describe '#perform' do

    it 'converts exams to events' do
      instance = subject.perform(exams: exams, faculty_semester: faculty_semester)
      events = instance.results[:events]
      event = events.first
      expect(events).to be
      expect(event.starts_at).to eq Time.parse('2015-01-12T11:00:00')
      expect(event.ends_at).to eq Time.parse('2015-01-12T12:00:00')
      expect(event.course_id).to eq 'BI-ZUM'
      expect(event.teacher_ids).to eq ['kordikp']
      expect(event.capacity).to eq 10
      expect(event.event_type).to eq 'exam'
      expect(event.semester).to eq 'B141'
      expect(event.faculty).to eq 18000
      expect(event.source).to eq(Sequel.hstore({ exam_id: 620283180005 }))
    end

    it 'outputs people' do
      instance = subject.perform(exams: exams, faculty_semester: faculty_semester)
      people = instance.results[:people]
      person = people.first
      expect(person.full_name).to eq 'Ing. Pavel Kordík Ph.D.'
      expect(person.id).to eq 'kordikp'
    end

    it 'outputs courses' do
      instance = subject.perform(exams: exams, faculty_semester: faculty_semester)
      courses = instance.results[:courses]
      course = courses.first
      expect(course.id).to eq 'BI-ZUM'
      expect(course.name).to eq({'cs' => 'Sample course'})
    end

    context 'with no examiner' do

      let(:teacher) { nil }

      it 'sets empty teacher_ids array' do
        instance = subject.perform(exams: exams, faculty_semester: faculty_semester)
        events = instance.results[:events]
        event = events.first
        expect(event.teacher_ids).to eq []
      end

    end

  end
end

