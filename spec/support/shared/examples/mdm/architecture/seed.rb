shared_examples_for 'Mdm::Architecture seed' do |attributes={}|
  it_should_behave_like 'Metasploit::Model::Architecture seed', attributes do
     subject(:seed) do
      described_class.where(:abbreviation => abbreviation).first
    end
  end
end