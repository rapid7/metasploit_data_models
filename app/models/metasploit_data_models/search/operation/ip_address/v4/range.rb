# Take an IPv4 range (`<IPv4 address>-<IPv4 address>`).
class MetasploitDataModels::Search::Operation::IPAddress::V4::Range < Metasploit::Model::Search::Operation::Base
  extend MetasploitDataModels::Match::Child

  #
  # CONSTANTS
  #

  # Regular expression for {MetasploitDataModels::Search::Operation::IPAddress::Match#match}
  MATCH_REGEXP = /\A#{MetasploitDataModels::IPAddress::V4::Range::REGEXP}\z/

  #
  # Validations
  #

  validate :format

  #
  # Instance Methods
  #

  def value=(formatted_value)
    match = MATCH_REGEXP.match(formatted_value.to_s)

    if match
      range_begin = IPAddr.new(match[:begin], Socket::AF_INET)
      range_end = IPAddr.new(match[:end], Socket::AF_INET)

      @value = Range.new(range_begin, range_end)
    else
      @value = formatted_value
    end
  end

  private

  # Validates `#value` is a range of IPv4 `IPAddr`s
  #
  # @return [void]
  def format
    if value.is_a? Range
      extremes_valid = true

      [:begin, :end].each do |extreme|
        extreme_value = value.send(extreme)

        unless MetasploitDataModels::Search::Operation::IPAddress::V4::Single.valid_value? extreme_value
          extremes_valid &= false
          errors.add(:value, :extreme, extreme: extreme, extreme_value: extreme_value.to_s)
        end
      end

      if extremes_valid && value.begin > value.end
        errors.add(:value, :order, begin: value.begin, end: value.end)
      end
    else
      errors.add(:value, :type)
    end
  end
end