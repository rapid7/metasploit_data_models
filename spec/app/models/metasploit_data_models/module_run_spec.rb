require 'spec_helper'

describe MetasploitDataModels::ModuleRun do

  context "associations" do
    it { is_expected.to belong_to(:user).class_name('Mdm::User') }
  end
end
