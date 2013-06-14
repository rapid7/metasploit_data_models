require 'spec_helper'

describe Mdm::Module::Instance do
  subject(:module_instance) do
    FactoryGirl.build(:mdm_module_instance)
  end

  let(:stances) do
    [
        'aggressive',
        'passive'
    ]
  end

  context 'associations' do
    it { should have_many(:actions).class_name('Mdm::Module::Action').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:module_architectures).class_name('Mdm::Module::Architecture').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:module_platforms).class_name('Mdm::Module::Platform').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:architectures).class_name('Mdm::Architecture').through(:module_architectures) }
    it { should have_many(:authors).class_name('Mdm::Module::Author').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should belong_to(:default_action).class_name('Mdm::Module::Action') }
    it { should belong_to(:default_target).class_name('Mdm::Module::Target') }
    it { should belong_to(:module_class).class_name('Mdm::Module::Class') }
    it { should have_many(:platforms).class_name('Mdm::Platform').through(:module_platforms) }
    it { should have_many(:refs).class_name('Mdm::Module::Ref').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:targets).class_name('Mdm::Module::Target').dependent(:destroy).with_foreign_key(:module_instance_id) }
  end

  context 'CONSTANTS' do
    context 'PRIVILEGES' do
      subject(:privileges) do
        described_class::PRIVILEGES
      end

      it 'should contain both Boolean values' do
        privileges.should include(false)
        privileges.should include(true)
      end
    end

    context 'STANCES' do
      subject(:stances) do
        described_class::STANCES
      end

      it { should include('aggressive') }
      it { should include('passive') }
    end
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:default_action_id).of_type(:integer).with_options(:null => true) }
      it { should have_db_column(:default_target_id).of_type(:integer).with_options(:null => true) }
      it { should have_db_column(:description).of_type(:text).with_options(:null => false) }
      it { should have_db_column(:disclosed_on).of_type(:date).with_options(:null => true) }
      it { should have_db_column(:license).of_type(:string).with_options(:null => false) }
      it { should have_db_column(:module_class_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:name).of_type(:text).with_options(:null => false) }
      it { should have_db_column(:privileged).of_type(:boolean).with_options(:null => false) }
      it { should have_db_column(:stance).of_type(:string).with_options(:null => true) }
    end

    context 'indices' do
      it { should have_db_index(:default_action_id).unique(true) }
      it { should have_db_index(:default_target_id).unique(true) }
      it { should have_db_index(:module_class_id).unique(true) }
    end
  end

  context 'factories' do
    context 'mdm_module_instance' do
      subject(:mdm_module_instance) do
        FactoryGirl.build(:mdm_module_instance)
      end

      it { should be_valid }

      context 'stance' do
        subject(:mdm_module_instance) do
          FactoryGirl.build(
              :mdm_module_instance,
              :module_class => module_class
          )
        end

        let(:module_class) do
          FactoryGirl.create(
              :mdm_module_class,
              :module_type => module_type
          )
        end

        context 'with supports_stance?' do
          let(:module_type) do
            'exploit'
          end

          it { should be_valid }

          its(:stance) { should_not be_nil }
          its(:supports_stance?) { should be_true }
        end

        context 'without supports_stance?' do
          let(:module_type) do
            'post'
          end

          it { should be_valid }

          its(:stance) { should be_nil }
          its(:supports_stance?) { should be_false }
        end
      end
    end
  end

  context 'validations' do
    it { should validate_presence_of :module_class }

    context 'ensure inclusion of privileged is boolean' do
      let(:error) do
        'is not included in the list'
      end

      before(:each) do
        module_instance.privileged = privileged

        module_instance.valid?
      end

      context 'with nil' do
        let(:privileged) do
          nil
        end

        it 'should record error' do
          module_instance.errors[:privileged].should include(error)
        end
      end

      context 'with false' do
        let(:privileged) do
          false
        end

        it 'should not record error' do
          module_instance.errors[:privileged].should be_empty
        end
      end

      context 'with true' do
        let(:privileged) do
          true
        end

        it 'should not record error' do
          module_instance.errors[:privileged].should be_empty
        end
      end
    end

    context 'stance' do
      context 'module_type' do
        subject(:module_instance) do
          FactoryGirl.build(
              :mdm_module_instance,
              :module_class => module_class,
              # set by shared examples
              :stance => stance
          )
        end

        let(:module_class) do
          FactoryGirl.create(
              :mdm_module_class,
              # set by shared examples
              :module_type => module_type
          )
        end

        let(:stance) do
          nil
        end

        it_should_behave_like 'Mdm::Module::Instance supports stance with module_type', 'auxiliary'
        it_should_behave_like 'Mdm::Module::Instance supports stance with module_type', 'exploit'

        it_should_behave_like 'Mdm::Module::Instance does not support stance with module_type', 'encoder'
        it_should_behave_like 'Mdm::Module::Instance does not support stance with module_type', 'nop'
        it_should_behave_like 'Mdm::Module::Instance does not support stance with module_type', 'payload'
        it_should_behave_like 'Mdm::Module::Instance does not support stance with module_type', 'post'
      end
    end
  end
end