shared_examples_for 'Mdm::Module::Path#changed_module_ancestor_from_real_path with handled' do
  it { should_not be_valid }

  it 'should have error on handler_type' do
    changed_module_ancestor_from_real_path.valid?
    changed_module_ancestor_from_real_path.errors[:handler_type].should include(I18n.translate('errors.messages.blank'))
  end

  it 'should not save module ancestor' do
    expect {
      changed_module_ancestor_from_real_path
    }.to_not change(Mdm::Module::Ancestor, :count)
  end

  context 'with handler_type' do
    let(:handler_type) do
      FactoryGirl.generate :metasploit_model_module_ancestor_handler_type
    end

    before(:each) do
      changed_module_ancestor_from_real_path.handler_type = handler_type
    end

    it 'should save without error' do
      expect {
        changed_module_ancestor_from_real_path.save!
      }.to_not raise_error
    end
  end
end