shared_examples_for 'MetasploitDataModels::Search::Visitor::Where#visit with Metasploit::Model::Search::Group::Base' do |options={}|
  options.assert_valid_keys(:arel_class)

  arel_class = options.fetch(:arel_class)

  let(:children) do
    2.times.collect { |n|
      double("Group Child #{n}")
    }
  end

  let(:node) do
    node_class.new(
        :children => children
    )
  end

  it 'should visit each child' do
    visitor.should_receive(:visit).with(node).and_call_original

    children.each do |child|
      visitor.should_receive(:visit).with(child).and_return(Arel::Nodes::Equality.new(1, 1))
    end

    visit
  end

  it "should combine children AREL with #{arel_class}" do
    visitor.stub(:visit).with(node).and_call_original
    child_visits = []

    children.each_with_index do |child, i|
      child_visit = Arel::Nodes::Equality.new(i, i)
      visitor.stub(:visit).with(child).and_return(child_visit)
      child_visits << child_visit
    end

    root = visit

    if root.is_a? Arel::Nodes::Grouping
      arel_pair = root.expr
    else
      arel_pair = root
    end

    arel_pair.should be_a arel_class

    expect([arel_pair.left, arel_pair.right]).to match_array(child_visits)
  end
end