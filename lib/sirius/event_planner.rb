require 'ice_cube'
require 'sirius/teaching_time'

module Sirius

  class EventPlanner

    def initialize( teaching_period:, first_week_parity: )
      @teaching_period = teaching_period
      @first_week_parity = first_week_parity
    end

    def plan(teaching_time)
      week_offset = teaching_time.week_offset(@first_week_parity)

      scheduling_start = @teaching_period.starts_at + teaching_time.starts_at.seconds_since_midnight.seconds + week_offset
      event_duration = (teaching_time.ends_at - teaching_time.starts_at)

      event_schedule = IceCube::Schedule.new(scheduling_start, duration: event_duration)
      event_schedule.add_recurrence_rule to_recurrence_rule(teaching_time)
      event_schedule.all_occurrences.map{ |event_start| Sirius::Period.new(event_start.to_time, event_start + event_duration) }
    end

    private
    def to_recurrence_rule(teaching_time)
      week_frequency = 1 #every week by default
      week_frequency = 2 if teaching_time.parity != :both

      IceCube::Rule.weekly(week_frequency, :monday).day(teaching_time.day).until(@teaching_period.ends_at)
    end

  end

end

