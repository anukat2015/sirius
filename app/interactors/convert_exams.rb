require 'interpipe/interactor'

class ConvertExams
  include Interpipe::Interactor

  def perform(exams:, faculty_semester:)
    @courses = {}
    @people = {}
    @faculty_semester = faculty_semester
    @events = exams.map do |exam|
      convert_exam(exam)
    end
  end

  def results
    {
      events: @events,
      courses: @courses.values,
      people: @people.values
    }
  end

  def convert_exam(exam)
    event = Event.new
    event.starts_at = exam.start_date
    event.ends_at = exam.end_date
    event.course_id = exam.course.link_id
    export_course(exam.course)
    event.teacher_ids = []
    if exam.examiner
      event.teacher_ids = [exam.examiner.link_id]
      export_person(exam.examiner)
    end
    event.capacity = exam.capacity
    event.event_type = 'exam'
    event.source = Sequel.hstore({exam_id: exam.link.link_id})
    event.semester = @faculty_semester.code
    event.faculty = @faculty_semester.faculty
    event
  end

  def export_person(person_link)
    username = person_link.link_id
    @people[username] ||= Person.new(full_name: person_link.link_title) { |p| p.id = username }
  end

  def export_course(course_link)
    course_code = course_link.link_id
    @courses[course_code] ||= Course.new(name: Sequel.hstore({cs: course_link.link_title})) { |c| c.id = course_code }
  end

end
