shared_examples_for 'Mdm::Module::Detail does not support stance with mtype' do |mtype|
  context "with #{mtype.inspect}" do
    # define as a let so that lets from outer context can access option to set detail.
    let(:mtype) do
      mtype
    end

    it 'should return false for supports_stance?' do
      detail.supports_stance?.should be_false
    end

    context 'with nil stance' do
      let(:stance) do
        nil
      end

      it { should be_valid }
    end
  end
end