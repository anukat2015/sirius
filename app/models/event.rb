require 'period'
require 'parallel'

class Event < Sequel::Model

  many_to_one :room
  many_to_one :course
  many_to_one :parallel
  many_to_one :timetable_slot

  alias :sequence_number :relative_sequence_number

  def self.with_person(username)
    teacher_op = Sequel.pg_array(:teacher_ids, :varchar)
    student_op = Sequel.pg_array(:student_ids, :varchar)
    filter(username => teacher_op.any).or(username => student_op.any)
  end

  def period
    Period.new(starts_at, ends_at)
  end

  def period=(new_period)
    self.starts_at = new_period.starts_at
    self.ends_at = new_period.ends_at
  end

  def move(offset)
    offset_int = offset.to_i
    self.starts_at += offset_int.minutes
    self.ends_at += offset_int.minutes
  end

end
