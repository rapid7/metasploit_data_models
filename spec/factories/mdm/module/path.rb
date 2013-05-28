FactoryGirl.define do
  factory :mdm_module_path, :aliases => [:unnamed_mdm_module_path], :class => Mdm::Module::Path do
    real_path { MetasploitDataModels.root.join('spec', 'dummy', 'modules').to_path }

    factory :named_mdm_module_path do
      gem { generate :mdm_module_path_gem }
      name { generate :mdm_module_path_name }
    end
  end

  sequence :mdm_module_path_gem do |n|
    "gem#{n}"
  end

  sequence :mdm_module_path_name do |n|
    "modules_#{n}"
  end
end