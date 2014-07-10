# Namespace for IPv4 addresses of various formatted.
class MetasploitDataModels::IPAddress::V4::Single < MetasploitDataModels::IPAddress::V4::Segmented
  #
  # Segments
  #

  segment class_name: 'MetasploitDataModels::IPAddress::V4::Segment::Single'
end