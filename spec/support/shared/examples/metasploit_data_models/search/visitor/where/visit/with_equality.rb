shared_examples_for 'MetasploitDataModels::Search::Visitor::Where#visit with equality operation' do
  let(:node) do
    node_class.new(
        :operator => operator,
        :value => value
    )
  end

  let(:operator) do
    Metasploit::Model::Search::Operator::Attribute.new(
        # any class that responds to arel_table
        :klass => Mdm::Host
    )
  end

  let(:value) do
    "value"
  end

  it 'should visit operation.operator with attribute_visitor' do
    visitor.attribute_visitor.should_receive(:visit).with(operator).and_call_original

    visit
  end

  it 'should call eq on Arel::Attributes::Attribute from attribute_visitor' do
    attribute = double('Visited Operator')
    visitor.attribute_visitor.stub(:visit).with(operator).and_return(attribute)

    attribute.should_receive(:eq).with(value)

    visit
  end
end