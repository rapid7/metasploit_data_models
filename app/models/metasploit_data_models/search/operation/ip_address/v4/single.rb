class MetasploitDataModels::Search::Operation::IPAddress::V4::Single < Metasploit::Model::Search::Operation::Base
  extend MetasploitDataModels::Match::Child

  #
  # CONSTANTS
  #

  # Regular expression for {MetasploitDataModels::Search::Operation::IPAddress::Match#match match}
  MATCH_REGEXP = /\A#{MetasploitDataModels::IPAddress::V4::REGEXP}\z/

  #
  # Validations
  #

  validate :format

  #
  # Class Methods
  #

  # Whether the IPAddr is a single IPv4 address and not a IPv4 range.
  #
  # @param value [Object, IPAddr]
  # @return [true] if `value` is IPv4 and contains only one IP address
  # @return [false] otherwise
  def self.valid_value?(value)
    if value.is_a?(IPAddr) && value.ipv4?
      range = value.to_range

      range.begin == value && range.end == value
    else
      false
    end
  end

  #
  # Instance Methods
  #

  #
  # @param formatted_value [#to_s]
  # @return [IPAddr]
  def value=(formatted_value)
    begin
      @value = IPAddr.new(formatted_value.to_s, Socket::AF_INET)
    rescue ArgumentError
      @value = formatted_value
    end
  end

  private

  # Validates that `#value` is an IPv4 address in an `IPAddr` containing an IPv4 address.
  #
  # @return [void]
  def format
    unless self.class.valid_value?(value)
      errors.add(:value, :format)
    end
  end
end