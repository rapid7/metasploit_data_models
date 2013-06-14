shared_examples_for 'Mdm::Authority seed' do |attributes={}|
  attributes.assert_valid_keys(:abbreviation, :obsolete, :summary, :url)

  abbreviation = attributes.fetch(:abbreviation)

  context "with #{abbreviation}" do
    subject(:seed) do
      described_class.where(:abbreviation => abbreviation).first
    end

    it 'should exist' do
      seed.should_not be_nil
    end

    its(:obsolete) { should == attributes.fetch(:obsolete) }
    its(:summary) { should == attributes.fetch(:summary) }
    its(:url) { should == attributes.fetch(:url) }
  end
end