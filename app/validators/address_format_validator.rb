 require 'ipaddr'
# Validates that attribute is a valid address.
class AddressFormatValidator < ActiveModel::EachValidator
  # Validates that `attribute`'s `value` on `object` is a valid address.
  #
  # @return [void]
  def validate_each(object, attribute, value)
    error_message_block = lambda{ object.errors.add attribute, "must be a valid (IP or hostname) address" }
    begin
      # Checks for valid IP addresses
      if value.is_a? IPAddr
        potential_ip = value.dup
      else
        potential_ip = IPAddr.new(value)
      end
      error_message_block.call unless potential_ip.ipv4? || potential_ip.ipv6?
    rescue IPAddr::InvalidAddressError, IPAddr::AddressFamilyError, ArgumentError
      # IP address resolution failed, checks for valid hostname
      error_message_block.call unless (value && value.match?(/\A#{URI::PATTERN::HOSTNAME}\z/))
    end
  end
end
