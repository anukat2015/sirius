require 'interpipe/interactor'

class ConvertParallels
  include Interpipe::Interactor

  DB_KEYS = [:code, :parallel_type, :capacity, :occupied]

  def setup
    @parallels = []
    @timetable_slots = {}
    @people = {}
    @courses = {}
    @rooms = {}
  end

  def perform(kosapi_parallels:, faculty_semester: nil)
    @faculty_semester = faculty_semester
    @parallels = kosapi_parallels.map do |kosapi_parallel|
      teachers = extract_teachers(kosapi_parallel)
      course = extract_course(kosapi_parallel)
      extract_slots(kosapi_parallel)
      build_parallel(kosapi_parallel, teachers, course)
    end
  end

  def build_parallel(kosapi_parallel, teachers, course)
    parallel_hash = kosapi_parallel.to_hash
    parallel_hash.select! { |key,_| DB_KEYS.include? key }
    parallel_hash[:semester] = kosapi_parallel.semester.link_id
    parallel = Parallel.new(parallel_hash) { |p| p.id = kosapi_parallel.link.link_id }
    parallel.teacher_ids = teachers
    parallel.course = course
    parallel.faculty = @faculty_semester.faculty
    parallel.deleted_at = nil
    parallel
  end

  def extract_teachers(kosapi_parallel)
    kosapi_parallel.teachers.map do |teacher_link|
      username = teacher_link.link_id
      person = @people[username] ||= Person.new(full_name: teacher_link.link_title) { |p| p.id = username}
      person.id
    end
  end

  def extract_course(kosapi_parallel)
    kosapi_course = kosapi_parallel.course
    course_id = kosapi_course.link_id
    @courses[course_id] ||= Course.new(name: Sequel.hstore({cs: kosapi_course.link_title})) { |c| c.id = course_id }
  end

  def extract_slots(kosapi_parallel)
    parallel_id = kosapi_parallel.link.link_id
    kosapi_parallel.timetable_slots.each { |slot| extract_rooms(slot) }
    @timetable_slots[parallel_id] = kosapi_parallel.timetable_slots
  end

  def extract_rooms(timetable_slot)
    @rooms[timetable_slot.room.link_id] = timetable_slot.room if timetable_slot.room
  end

  def results
    {
        parallels: @parallels,
        timetable_slots: @timetable_slots,
        people: @people.values,
        courses: @courses.values,
        kosapi_rooms: @rooms.values,
        faculty_semester: @faculty_semester
    }
  end

end
