# A range of segment number composed of a {#begin} and {#end} segment number, separated by a `-`.
class MetasploitDataModels::IPAddress::V4::Segment::Nmap::Range < Metasploit::Model::Base
  extend MetasploitDataModels::Match::Child

  #
  # CONSTANTS
  #

  # The name of the extremes of a range.
  EXTREMES = [
      :begin,
      :end
  ]

  # Separator between the {#begin} and {#end} in the formatted value.
  SEPARATOR = '-'

  # Segment numbers separated by {SEPARATOR}, signifying a continuous range from the `START` to `END`, inclusive.
  REGEXP = /#{MetasploitDataModels::IPAddress::V4::Segment::Single::REGEXP}#{SEPARATOR}#{MetasploitDataModels::IPAddress::V4::Segment::Single::REGEXP}/

  # Matches a string with only a range in it.
  MATCH_REGEXP = /\A#{REGEXP}\z/

  # @!attribute value
  #   The range.
  #
  #   @return [Range<Integer, Integer>, String]
  attr_reader :value

  #
  #
  # Validations
  #
  #

  #
  # Validation Methods
  #

  validate :extremes_valid
  validate :order

  #
  # Validation Attriubtes
  #

  validates :begin,
            presence: true
  validates :end,
            presence: true

  #
  # Instance Methods
  #

  # Begin of segment range.
  #
  # @return [MetasploitDataModels::IPAddress::V4::NMAP::Segment::Number] if {#value} is a `Range`.
  # @return [nil] if {#value} is not a `Range`.
  def begin
    if value.respond_to? :begin
      value.begin
    end
  end

  # End of segment range.
  #
  # @return [MetasploitDataModels::IPAddress::V4::NMAP::Segment::Number] if {#value} is a `Range`.
  # @return [nil] if {#value} is not a `Range`.
  def end
    if value.respond_to? :end
      value.end
    end
  end

  # This range as a string.  Equivalent to the original `formatted_value` passed to {#value}.
  #
  # @return [String]
  def to_s
    "#{self.begin}-#{self.end}"
  end

  # Sets {#value} by breaking up the range into its begin and end Integers.
  #
  # @param formatted_value [#to_s]
  # @return [Range<Integer, Integer>] if {SEPARATOR} is used and both extremes are Integers.
  # @return [#to_s] `formatted_value` if it could not be converted
  def value=(formatted_value)
    formatted_extremes = formatted_value.to_s.split(SEPARATOR, 2)

    extremes = formatted_extremes.map { |formatted_extreme|
      MetasploitDataModels::IPAddress::V4::Segment::Single.new(value: formatted_extreme)
    }

    begin
      @value = Range.new(*extremes)
    rescue ArgumentError
      @value = formatted_value
    end
  end

  private

  # Validates that {#begin} and {#end} are valid.
  #
  # @return [void]
  def extremes_valid
    EXTREMES.each do |extreme_name|
      extreme_value = send(extreme_name)

      unless extreme_value.respond_to?(:valid?) && extreme_value.valid?
        errors.add(extreme_name, :invalid)
      end
    end
  end

  # Validates that {#begin} is `<=` {#end}.
  #
  # @return [void]
  def order
    if self.begin && self.end && self.begin > self.end
      errors.add(:value, :order, begin: self.begin, end: self.end)
    end
  end
end