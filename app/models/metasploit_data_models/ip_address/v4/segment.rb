# A segment number in an IPv4 address or the
# {MetasploitDataModels::IPAddress::V4::Segment::Nmap::Range#begin} or
# {MetasploitDataModels::IPAddress::V4::Segment::Nmap::Range#send}.
class MetasploitDataModels::IPAddress::V4::Segment < Metasploit::Model::Base
  extend MetasploitDataModels::Match::Child

  include Comparable

  #
  # CONSTANTS
  #

  #
  # CONSTANTS
  #

  # Number of bits in a IPv4 segment
  BITS = 8

  # Maximum segment {#value}
  MAXIMUM = (1 << BITS) - 1

  # Minimum segment {#value}
  MINIMUM = 0

  # Regular expression for a segment (octet) of an IPv4 address in decimal dotted notation.
  #
  # @see http://stackoverflow.com/a/17871737/470451
  REGEXP = /(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])/

  # Match only strings that contain exactly a segment.
  #
  # Used by {MetasploitDataModels::IPAddress::V4::Segment::Nmap} to determine if a string should be a
  # {MetasploitDataModels::IPAddress::V4::Segment::Nmap::Number} or
  # {MetasploitDataModels::IPAddress::V4::Segment::Nmap::Range}.
  MATCH_REGEXP = /\A#{REGEXP}\z/

  #
  # Attributes
  #

  # @!attribute value
  #   The segment number.
  #
  #   @return [Integer, String]
  attr_reader :value

  #
  # Validations
  #

  validates :value,
            numericality: {
                greater_than_or_equal_to: MetasploitDataModels::IPAddress::V4::Segment::MINIMUM,
                less_than_or_equal_to: MetasploitDataModels::IPAddress::V4::Segment::MAXIMUM,
                only_integer: true
            }

  #
  # Instance Methods
  #


  def <=>(other)
    value <=> other.value
  end

  def succ
    if value.respond_to? :succ
      self.class.new(value: value.succ)
    end
  end

  delegate :to_s,
           to: :value

  # Sets {#value} by type casting String to Integer.
  #
  # @param formatted_value [#to_s]
  # @return [Integer] if `formatted_value` contains only an Integer#to_s
  # @return [#to_s] `formatted_value` if it does not contain an Integer#to_s
  def value=(formatted_value)
    @value_before_type_cast = formatted_value

    begin
      # use Integer() instead of String#to_i as String#to_i will ignore trailing letters (i.e. '1two' -> 1) and turn all
      # string without an integer in it to 0.
      @value = Integer(formatted_value.to_s)
    rescue ArgumentError
      @value = formatted_value
    end
  end
end