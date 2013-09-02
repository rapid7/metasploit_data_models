shared_examples_for 'MetasploitDataModels::Search::Visitor::Relation#visit matching record with Metasploit::Model::Search::Operator::Deprecated::Platform' do |options={}|
  options.assert_valid_keys(:name)

  name = options.fetch(:name)

  context "with #{name}" do
    let(:formatted) do
      "#{name}:\"#{value}\""
    end

    context 'with Mdm::Platform#name' do
      let(:value) do
        matching_record.platforms.sample.name
      end

      it 'should find only matching record' do
        expect(visit).to match_array([matching_record])
      end
    end

    context 'with Mdm::Module::Target#name' do
      let(:value) do
        matching_record.targets.sample.name
      end

      it 'should find only matching record' do
        expect(visit).to match_array([matching_record])
      end
    end
  end
end