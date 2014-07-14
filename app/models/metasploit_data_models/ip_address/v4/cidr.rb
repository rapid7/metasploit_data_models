class MetasploitDataModels::IPAddress::V4::CIDR < Metasploit::Model::Base
  include MetasploitDataModels::IPAddress::CIDR

  #
  # CIDR
  #

  cidr address_class: MetasploitDataModels::IPAddress::V4::Single
end