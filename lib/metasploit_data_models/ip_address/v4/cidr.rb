module MetasploitDataModels::IPAddress::V4::CIDR
  #
  # CONSTANTS
  #

  # [Classless Inter-Domain Routing notation](https://en.wikipedia.org/wiki/Cidr#CIDR_notation) for IPv4 addresses
  # regular expression.
  REGEXP = %r{#{MetasploitDataModels::IPAddress::V4::REGEXP}/(?<routing_prefix_bits>3[0-2]|[12][0-9]|[0-9])}
end