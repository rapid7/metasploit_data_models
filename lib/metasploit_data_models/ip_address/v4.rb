# Namespace for IPv4 addresses of various formatted.
module MetasploitDataModels::IPAddress::V4
  extend ActiveSupport::Autoload

  autoload :CIDR
  autoload :Segment

  #
  # CONSTANTS
  #

  # Regular expression for an IPv4 address in decimal dotted notation.
  #
  # @see http://stackoverflow.com/a/17871737/470451
  REGEXP = /(#{self::Segment::REGEXP}\.){3,3}#{self::Segment::REGEXP}/
end