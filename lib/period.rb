class Period

  attr_reader :starts_at, :ends_at

  def initialize(starts_at, ends_at)

    @starts_at = starts_at
    @ends_at = ends_at
  end


  def ==(other)
    @starts_at == other.starts_at && @ends_at == other.ends_at
  end

  def self.parse(start_str, end_str)
    Period.new(Time.parse(start_str), Time.parse(end_str))
  end

  def include?(other_period)
    starts_at <= other_period.starts_at && ends_at >= other_period.ends_at
  end

end
