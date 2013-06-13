shared_examples_for 'Mdm::Architecture seed' do |attributes={}|
  attributes.assert_valid_keys(:abbreviation, :bits, :endianness, :family, :summary)

  abbreviation = attributes.fetch(:abbreviation)

  context "with #{abbreviation}" do
    subject(:seed) do
      described_class.where(:abbreviation => abbreviation).first
    end

    it 'should exist' do
      seed.should_not be_nil
    end

    its(:bits) { should == attributes.fetch(:bits) }
    its(:endianness) { should == attributes.fetch(:endianness) }
    its(:family) { should == attributes.fetch(:family) }
    its(:summary) { should == attributes.fetch(:summary) }
  end
end