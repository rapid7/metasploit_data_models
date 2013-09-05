shared_examples_for 'Mdm::Module::Path#changed_module_ancestor_from_real_path without handled' do
  it { should be_valid }

  it 'should not save module ancestor' do
    expect {
      changed_module_ancestor_from_real_path
    }.to_not change(Mdm::Module::Ancestor, :count)
  end

  it 'should save without errors' do
    expect {
      changed_module_ancestor_from_real_path.save!
    }.to_not raise_error
  end
end
