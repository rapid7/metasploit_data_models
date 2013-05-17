shared_examples_for 'Mdm::Module::Detail supports stance with mtype' do |mtype|
  context "with #{mtype.inspect}" do
    # define as a let so that lets from outer context can access option to set detail.
    let(:mtype) do
      mtype
    end

    it 'should return true for supports_stance?' do
      detail.supports_stance?.should be_true
    end

    context 'with nil stance' do
      let(:stance) do
        nil
      end

      it { should be_invalid }
    end

    context "with 'aggresive' stance" do
      let(:stance) do
        'aggressive'
      end

      it { should be_valid }
    end

    context "with 'passive' stance" do
      let(:stance) do
        'passive'
      end

      it { should be_valid }
    end
  end
end