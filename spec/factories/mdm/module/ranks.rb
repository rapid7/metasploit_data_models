FactoryGirl.define do
  # Mdm::Module::Rank does not have a factory because all valid records are seeded, so it only has a sequence to grab
  # a seeded record

  names = Mdm::Module::Rank::NUMBER_BY_NAME.keys

  sequence :mdm_module_rank do |n|
    name = names[n % names.length]

    rank = Mdm::Module::Rank.where(:name => name).first

    unless rank
      raise ArgumentError,
            "Mdm::Module::Rank with name (#{name}) has not been seeded."
    end

    rank
  end
end