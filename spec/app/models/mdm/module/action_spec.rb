require 'spec_helper'

describe Mdm::Module::Action do
  context 'associations' do
    it { should belong_to(:detail).class_name('Mdm::Module::Detail') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:detail_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:name).of_type(:text).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index([:detail_id, :name]).unique(true) }
    end
  end

  context 'factories' do
    context 'mdm_module_action' do
      subject(:mdm_module_action) do
        FactoryGirl.build(:mdm_module_action)
      end

      it { should be_valid }
    end
  end

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of(:detail_id) }
    it { should allow_mass_assignment_of(:name) }
  end

  context 'validations' do
    it { should validate_presence_of(:detail) }

    context 'name' do
      it { should validate_presence_of(:name) }

      context 'validate uniqueness of name scoped to detail_id' do
        let(:error_message) do
          'has already been taken'
        end

        let!(:existing_action) do
          FactoryGirl.create(:mdm_module_action)
        end

        context 'with same detail_id' do
          let(:new_action) do
            FactoryGirl.build(:mdm_module_action, :detail => existing_action.detail)
          end

          it 'should not allow same name' do
            new_action.name = existing_action.name

            new_action.name.should == existing_action.name
            new_action.should_not be_valid
            new_action.errors[:name].should include(error_message)
          end

          it 'should allow different name' do
            new_action.name = FactoryGirl.generate :mdm_module_action_name

            new_action.name.should_not == existing_action.name
            new_action.should be_valid
            new_action.errors[:name].should_not include(error_message)
          end
        end

        context 'without same detail_id' do
          let(:new_action) do
            FactoryGirl.build(:mdm_module_action, :detail => new_detail)
          end

          let(:new_detail) do
            FactoryGirl.create(
                :mdm_module_detail,
                :parent_path => existing_action.detail.parent_path
            )
          end

          it 'should allow same name' do
            new_action.name = existing_action.name

            new_action.detail_id.should_not == existing_action.detail_id
            new_action.should be_valid
            new_action.errors[:name].should_not include(error_message)
          end

          it 'should allow different name' do
            new_action.name = FactoryGirl.generate :mdm_module_action_name

            new_action.name.should_not == existing_action.name
            new_action.should be_valid
            new_action.errors[:name].should_not include(error_message)
          end
        end
      end
    end
  end
end