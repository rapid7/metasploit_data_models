shared_examples_for 'Mdm::Authority seed' do |attributes={}|
  attributes.assert_valid_keys(:abbreviation, :extension_name, :obsolete, :summary, :url)

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

    extension_name = attributes.fetch(:extension_name)

    if extension_name
      context 'with extension' do
        let(:designation) do
          mock('Designation')
        end

        let(:extension) do
          extension_name.constantize
        end

        its(:extension) { should == extension }

        it 'should have extension be a defined class' do
          expect {
            extension
          }.to_not raise_error(NameError)
        end

        it 'should delegate #designation_url to extension' do
          extension.should_receive(:designation_url).with(designation)

          seed.designation_url(designation)
        end
      end
    else
      its(:extension) { should be_nil }
    end
  end
end