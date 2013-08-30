shared_examples_for 'MetasploitDataModels::Search::Visitor::Includes#visit with #children' do
  let(:children) do
    2.times.collect { |n|
      double("Child #{n}")
    }
  end

  let(:node) do
    node_class.new(
        :children => children
    )
  end

  it 'should visit each child' do
    # needed for call to visit subject
    visitor.should_receive(:visit).with(node).and_call_original

    children.each do |child|
      visitor.should_receive(:visit).with(child).and_return([])
    end

    visit
  end

  it 'should return Array of all child visits' do
    child_visits = []

    visitor.should_receive(:visit).with(node).and_call_original

    children.each_with_index do |child, i|
      child_visit = ["Visited Child #{i}"]
      visitor.stub(:visit).with(child).and_return(child_visit)
      child_visits.concat(child_visit)
    end

    visit.should == child_visits
  end
end