class MetasploitDataModels::Search::Operation::IPAddress::V4::Single < Metasploit::Model::Search::Operation::Base
  extend MetasploitDataModels::Search::Operation::IPAddress::Match

  #
  # CONSTANTS
  #

  # Regular expression for a segment (octet) of an IPv4 address in decimal dotted notation
  # @see http://stackoverflow.com/a/17871737/470451
  SEGMENT_REGEXP = /(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])/

  # Regular expression for an IPv4 address in decimal dotted notation
  # @see http://stackoverflow.com/a/17871737/470451
  ADDRESS_REGEXP = /(#{SEGMENT_REGEXP}\.){3,3}#{SEGMENT_REGEXP}/

  # Regular expression for {MetasploitDataModels::Search::Operation::IPAddress::Match#match match}
  MATCH_REGEXP = /\A#{ADDRESS_REGEXP}\z/

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