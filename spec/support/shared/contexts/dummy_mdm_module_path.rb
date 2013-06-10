# Defines an {Mdm::Module::Path} instance that points to spec/dummy/modules so that {Mdm::Module::Path#real_path} is
# valid.
shared_context 'dummy Mdm::Module::Path' do
  let(:dummy_mdm_module_path) do
    FactoryGirl.create(
        :mdm_module_path,
        :gem => 'metasploit_data_models',
        :name => 'dummy',
        :real_path => dummy_mdm_module_path_real_path
    )
  end

  let(:dummy_mdm_module_path_real_path) do
    dummy_mdm_module_path_real_pathname.to_path
  end

  let(:dummy_mdm_module_path_real_pathname) do
    MetasploitDataModels.root.join('spec', 'dummy', 'modules')
  end

  before(:each) do
    dummy_mdm_module_path_real_pathname.mkpath
  end

  after(:each) do
    dummy_mdm_module_path_real_pathname.rmtree
  end
end