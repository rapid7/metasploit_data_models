class MetasploitDataModels::IPAddress::V4::Segment::Nmap < Metasploit::Model::Base
  extend ActiveSupport::Autoload
  extend MetasploitDataModels::Match::Child

  include MetasploitDataModels::Match::Parent

  relative_child_names = %w{Number Range}

  relative_child_names.each do |relative_child_name|
    autoload relative_child_name
  end

  #
  # CONSTANTS
  #

  # Either an individual {MetasploitDataModels::IPAddress::V4::Segment::Nmap::Number segment number} or a
  # {MetasploitDataModels::IPAddress::V4::Segment::Nmap::Range segment range}.
  RANGE_OR_NUMBER_REGEXP = %r{
      (?<range>#{self::Range::REGEXP})
      |
      # range first because it contains a segment and if the range isn't first only the first part of the range will
      # match.
      (?<number>#{MetasploitDataModels::IPAddress::V4::Segment::REGEXP})
  }x
  # Segment of an NMAP address, composed of comma separated {RANGE_OR_NUMBER_REGEXP segment numbers or ranges}.
  REGEXP = /#{RANGE_OR_NUMBER_REGEXP}(,#{RANGE_OR_NUMBER_REGEXP})*/

  # Matches exactly an Nmap comma separated list of segment numbers and ranges.
  MATCH_REGEXP = /\A#{REGEXP}\z/

  #
  # Attributes
  #

  # @!attribute value
  #   The NMAP IPv4 octect range.
  #
  #   @return [Array<MetasploitDataModels::IPAddress::V4::Segment::Number, MetasploitDataModels::IPAddress::V4::Segment::Range>]
  #     number and range in the order they appeared in formatted value.
  attr_reader :value

  #
  # Match Children
  #

  match_children_named relative_child_names.map { |relative_child_name|
    "#{name}::#{relative_child_name}"
  }

  #
  #
  # Validations
  #
  #

  #
  # Method Validations
  #

  validate :value_elements_valid
  validate :value_is_array

  #
  # Attribute Validations
  #

  validates :value,
            presence: true

  #
  # Instance Methods
  #

  def value=(formatted_value)
    string = formatted_value.to_s
    match = REGEXP.match(string)

    if match
      ranges_or_numbers = string.split(',')

      @value = ranges_or_numbers.map { |range_or_number|
        match_child(range_or_number) || range_or_number
      }
    else
      @value = formatted_value
    end
  end

  private

  # Validates that {#value}'s elements are all valid.
  #
  # @return [void]
  def value_elements_valid
    if value.is_a? Array
      value.each_with_index do |element, index|
        unless element.valid?
          errors.add(:value, :element, element: element, index: index)
        end
      end
    end
  end

  # Validates that {#value} is an `Array`.
  #
  # @return [void]
  def value_is_array
    unless value.is_a? Array
      errors.add(:value, :array)
    end
  end
end