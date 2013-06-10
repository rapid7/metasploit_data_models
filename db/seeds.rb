Mdm::Module::Rank::NUMBER_BY_NAME.each do |name, number|
  Mdm::Module::Rank.where(:name => name, :number => number).first_or_create!
end