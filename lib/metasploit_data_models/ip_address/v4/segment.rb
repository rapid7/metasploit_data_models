# Constants for the segments (the number separated by dots) in IPv4 addresses.
module MetasploitDataModels::IPAddress::V4::Segment
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
end