# Namespace for IPv4 addresses of various formatted.
class MetasploitDataModels::IPAddress::V4::Single < MetasploitDataModels::IPAddress::V4::Segmented
  #
  # Segments
  #

  segment class_name: 'MetasploitDataModels::IPAddress::V4::Segment::Single'

  #
  # Instance Methods
  #

  def +(other)
    unless other.is_a? self.class
      raise TypeError, "Cannot add #{other.class} to #{self.class}"
    end

    carry = 0
    sum_segments = []
    low_to_high_segments = segments.zip(other.segments).reverse

    low_to_high_segments.each do |self_segment, other_segment|
      segment, carry = self_segment.add_with_carry(other_segment, carry)
      sum_segments.unshift segment
    end

    unless carry == 0
      raise ArgumentError,
            "#{self} + #{other} is not a valid IP address.  It is #{sum_segments.join('.')} with a carry (#{carry})"
    end

    self.class.new(segments: sum_segments)
  end

  def succ
    self + self.class.new(value: '0.0.0.1')
  end
end