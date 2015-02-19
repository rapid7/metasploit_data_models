require 'spec_helper'

describe MetasploitDataModels::ModuleRun do

  subject(:module_run){FactoryGirl.build(:module_run)}

  context "associations" do
    it { is_expected.to belong_to(:user).class_name('Mdm::User') }
    it { is_expected.to belong_to(:trackable) }
  end

  context "validations" do
    describe "attempted_at" do
      before(:each){ module_run.attempted_at = nil }

      it { is_expected.to_not be_valid } 
    end

    describe "content information" do
      context "when there is no module_name and no module_detail" do
        before(:each) do
          module_run.module_name   = nil
          module_run.module_detail = nil
        end

        it { is_expected.to_not be_valid }
      end
    end


    describe "status" do
      describe "invalidity" do
        before(:each) do
          module_run.status = "invalid nonsense"
        end

        it { expect(module_run).to_not be_valid}
      end

      describe "validity" do
        context "when the module run succeeded" do
          before(:each){ module_run.status = MetasploitDataModels::ModuleRun::SUCCEED}

          it{ expect(module_run).to be_valid }
        end

        context "when the module run went normally but failed" do
          before(:each){ module_run.status = MetasploitDataModels::ModuleRun::FAIL}

          it{ expect(module_run).to be_valid }
        end

        context "when the module run errored out" do
          before(:each){ module_run.status = MetasploitDataModels::ModuleRun::ERROR}

          it{ expect(module_run).to be_valid }
        end

      end

    end
  end
end

