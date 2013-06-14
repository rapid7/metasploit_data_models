require 'spec_helper'

describe Mdm::Module::Platform do
  context 'associations' do
    it { should belong_to(:module_instance).class_name('Mdm::Module::Instance') }
    it { should belong_to(:platform).class_name('Mdm::Platform') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:module_instance_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:platform_id).of_type(:integer).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index([:module_instance_id, :platform_id]).unique(true) }
    end
  end

  context 'factories' do
    context 'mdm_module_platform' do
      subject(:mdm_module_platform) do
        FactoryGirl.build :mdm_module_platform
      end

      it { should be_valid }
    end
  end

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of(:module_instance_id) }
    it { should_not allow_mass_assignment_of(:platform_id) }
  end

  context 'validations' do
    it { should validate_presence_of :module_instance }
    it { should validate_presence_of :platform }

    # Can't use validate_uniqueness_of(:platform_id).scoped_to(:module_instance_id) because it will attempt to set
    # module_instance_id to nil.
    context 'validate uniqueness of platform_id scoped to module_instance_id' do
      let(:existing_module_instance) do
        FactoryGirl.create(:mdm_module_instance)
      end

      let(:existing_platform) do
        FactoryGirl.create(:mdm_platform)
      end

      let!(:existing_module_platform) do
        FactoryGirl.create(
            :mdm_module_platform,
            :module_instance => existing_module_instance,
            :platform => existing_platform
        )
      end

      context 'with same platform_id' do
        subject(:new_module_platform) do
          FactoryGirl.build(
              :mdm_module_platform,
              :module_instance => existing_module_instance,
              :platform => existing_platform
          )
        end

        it { should_not be_valid }

        it 'should record error on platform_id' do
          new_module_platform.valid?

          new_module_platform.errors[:platform_id].should include('has already been taken')
        end
      end

      context 'without same platform_id' do
        subject(:new_module_platform) do
          FactoryGirl.build(
              :mdm_module_platform,
              :module_instance => existing_module_instance,
              :platform => new_platform
          )
        end

        let(:new_platform) do
          FactoryGirl.create(:mdm_platform)
        end

        it { should be_valid }
      end
    end
  end
end