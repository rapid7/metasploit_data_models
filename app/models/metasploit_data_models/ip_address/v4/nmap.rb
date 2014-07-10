class MetasploitDataModels::IPAddress::V4::Nmap < Metasploit::Model::Base
  #
  # CONSTANTS
  #

  # Separator between segments.
  SEPARATOR = '.'
  # Regular expression for NMAP octet range format
  REGEXP = /(#{parent::Segment::Nmap::REGEXP}#{Regexp.escape(SEPARATOR)}){3,3}#{parent::Segment::Nmap::REGEXP}/
  # Regex for {#value} and {MetasploitDataModels::Match::Child#match}
  MATCH_REGEXP = /\A#{REGEXP}\z/

  #
  # Attributes
  #

  # @!attribute value
  #   Segments of IP address from high to low.
  #
  #   @return [Array<MetasploitDataModels::IPAddress:V4::Segment::Nmap>]
  attr_reader :value

  #
  #
  # Validations
  #
  #

  #
  # Validation Methods
  #

  validate :segments_valid

  #
  # Attribute Validations
  #

  validates :segments,
            length: {
              is: 4
            }

  #
  # Instance methods
  #

  # Array of segments.
  #
  # @return [Array] if {#value} is an `Array`.
  # @return [[]] if {#value} is not an `Array`.
  def segments
    if value.is_a? Array
      value
    else
      []
    end
  end

  # Sets {#value} by parsing its segments.
  #
  # @param formatted_value [#to_s]
  def value=(formatted_value)
    string = formatted_value.to_s
    match = MATCH_REGEXP.match(string)

    if match
      segments = string.split(SEPARATOR)

      @value = segments.map { |segment|
        MetasploitDataModels::IPAddress::V4::Segment::Nmap.new(value: segment)
      }
    else
      @value = formatted_value
    end
  end

  private

  # Validates that all segments in {#segments} are valid.
  #
  # @return [void]
  def segments_valid
    segments.each_with_index do |segment, index|
      unless segment.valid?
        errors.add(:segments, :segment_invalid, index: index, segment: segment)
      end
    end
  end
end