shared_examples_for 'MetasploitDataModels::Search::Visitor::Relation#visit matching record' do |options={}|
  options.assert_valid_keys(:attribute, :association)

  attribute = options.fetch(:attribute)
  association = options[:association]

  if association
    formatted_operator = "#{association}.#{attribute}"
  else
    formatted_operator = attribute.to_s
  end

  context "with #{formatted_operator}" do
    let(:formatted) do
      "#{formatted_operator}:\"#{value}\""
    end

    if association
      let(:associated) do
        # wrap in array so single and plural associations can be handled the same.
        Array.wrap(matching_record.send(association)).first
      end

      let(:value) do
        associated.send(attribute)
      end
    else
      let(:value) do
        matching_record.send(attribute)
      end
    end

    it 'should find only matching record' do
      expect(visit).to match_array([matching_record])
    end
  end
end