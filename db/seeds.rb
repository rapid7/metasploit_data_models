Metasploit::Model::Architecture::SEED_ATTRIBUTES.each do |attributes|
  Mdm::Architecture.where(attributes).first_or_create!
end

Metasploit::Model::Authority::SEED_ATTRIBUTES.each do |attributes|
  abbreviation = attributes.fetch(:abbreviation)

  # abbreviation is the only unique and :null => false column, so use it to look for updates.  Authority may be updated
  # if obsolete, summary, or url are currently nil, but attributes has non-nil value as could occur if authority is made
  # from module metadata before a seed exists.
  authority = Mdm::Authority.where(:abbreviation => abbreviation).first_or_initialize

  # can use ||= with boolean column because whoever asserts the authority is obsolete wins
  authority.obsolete ||= attributes.fetch(:obsolete)

  authority.summary ||= attributes.fetch(:summary)
  authority.url ||= attributes.fetch(:url)

  authority.save!
end

Mdm::Module::Rank::NUMBER_BY_NAME.each do |name, number|
  Mdm::Module::Rank.where(:name => name, :number => number).first_or_create!
end