require 'spec_helper'

describe MetasploitDataModels::ModuleRun do

  subject(:module_run){FactoryGirl.build(:module_run)}

  context "database columns" do
    it { is_expected.to have_db_column(:attempted_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:fail_detail).of_type(:text) }
    it { is_expected.to have_db_column(:fail_reason).of_type(:string) }
    it { is_expected.to have_db_column(:module_detail_id).of_type(:integer) }
    it { is_expected.to have_db_column(:module_name).of_type(:text) }
    it { is_expected.to have_db_column(:port).of_type(:integer) }
    it { is_expected.to have_db_column(:proto).of_type(:string) }
    it { is_expected.to have_db_column(:session_id).of_type(:integer) }
    it { is_expected.to have_db_column(:status).of_type(:string) }
    it { is_expected.to have_db_column(:trackable_id).of_type(:integer) }
    it { is_expected.to have_db_column(:trackable_type).of_type(:string) }
    it { is_expected.to have_db_column(:user_id).of_type(:integer) }
    it { is_expected.to have_db_column(:username).of_type(:string) }
  end

  context "associations" do
    it { is_expected.to belong_to(:user).class_name('Mdm::User') }
    it { is_expected.to belong_to(:target_session).class_name('Mdm::Session') }
    it { is_expected.to belong_to(:trackable) }
    it { is_expected.to have_one(:spawned_session).class_name('Mdm::Session') }
  end

  context "validations" do
    describe "when a session is set on the module run" do
      before(:each) do
        module_run.target_session = FactoryGirl.build(:mdm_session)
      end

      context "when module_name is present" do
        context "when the module is an exploit" do
          before(:each){ module_run.module_name = 'exploit/windows/mah-crazy-exploit' }

          it { is_expected.to_not be_valid }
        end
      end

      context "when module_detail is present" do
        before(:each) do
          module_run.module_detail = FactoryGirl.create(:mdm_module_detail, fullname: 'exploit/windows/some-evil')
        end

        it { is_expected.to_not be_valid }
      end
    end

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

