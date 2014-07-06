shared_examples_for 'MetasploitDataModels::Search::Visitor::Includes#visit with Metasploit::Model::Search::Operation::Base' do
  let(:operator) do
    double('Operation Operator')
  end

  let(:node) do
    node_class.new(
        :operator => operator
    )
  end

  it 'should visit operator' do
    visitor.should_receive(:visit).with(node).and_call_original
    visitor.should_receive(:visit).with(operator).and_return([])

    visit
  end

  it 'should return operator visit' do
    operator_visit = ["Visited Operator"]
    visitor.should_receive(:visit).with(node).and_call_original
    visitor.stub(:visit).with(operator).and_return(operator_visit)

    visit.should == operator_visit
  end
end
