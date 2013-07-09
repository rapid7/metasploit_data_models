FactoryGirl.define do
  factory :mdm_module_path, :aliases => [:unnamed_mdm_module_path], :class => Mdm::Module::Path do
    real_path { generate :mdm_module_path_real_path }

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

  sequence :mdm_module_path_real_path do |n|
    pathname = Metasploit::Model::Spec.temporary_pathname.join('mdm', 'module', 'path', 'real', 'path', n.to_s)
    Metasploit::Model::Spec::PathnameCollision.check!(pathname)
    pathname.mkpath

    pathname.to_path
  end
end