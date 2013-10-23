FactoryGirl.define do
  fully_qualified_names = Metasploit::Model::Platform.fully_qualified_name_set.sort
  platform_count = fully_qualified_names.length

  sequence :mdm_platform do |n|
    fully_qualified_name = fully_qualified_names[n % platform_count]

    platform = Mdm::Platform.where(fully_qualified_name: fully_qualified_name).first

    unless platform
      raise ArgumentError,
            "Mdm::Platform with fully_qualified_name (#{fully_qualified_name}) has not been seeded."
    end

    platform
  end
end