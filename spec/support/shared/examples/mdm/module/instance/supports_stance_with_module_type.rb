shared_examples_for 'Mdm::Module::Instance supports stance with module_type' do |context_module_type|
  context "with #{context_module_type.inspect}" do
    # define as a let so that lets from outer context can access option to set detail.
    let(:module_type) do
      context_module_type
    end

    it "should have #{context_module_type.inspect} for module_class.module_type" do
      module_instance.module_class.module_type.should == module_type
    end

    it 'should return true for supports_stance?' do
      module_instance.supports_stance?.should be_true
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