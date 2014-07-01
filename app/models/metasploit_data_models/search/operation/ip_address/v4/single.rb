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
    if value.is_a? IPAddr
      range = value.to_range

      unless value.ipv4? && range.begin == value && range.end == value
        errors.add(:value, :format)
      end
    else
      errors.add(:value, :format)
    end
  end
end