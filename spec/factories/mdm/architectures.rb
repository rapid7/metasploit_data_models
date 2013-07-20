FactoryGirl.define do
  abbreviations = Metasploit::Model::Architecture::ABBREVIATIONS

  # mdm_architectures is not a factory, but a sequence because only the seeded Mdm::Architectures are valid
  sequence :mdm_architecture do |n|
    # use abbreviations since they are unique
    abbreviation = abbreviations[n % abbreviations.length]
    architecture = Mdm::Architecture.where(:abbreviation => abbreviation).first

    architecture
  end
end