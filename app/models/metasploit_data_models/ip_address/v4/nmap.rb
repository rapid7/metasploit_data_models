class MetasploitDataModels::IPAddress::V4::Nmap < MetasploitDataModels::IPAddress::V4::Segmented
  #
  # Segments
  #

  segment class_name: 'MetasploitDataModels::IPAddress::V4::Segment::Nmap::List'
end