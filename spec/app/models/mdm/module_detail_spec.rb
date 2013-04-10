require 'spec_helper'

describe Mdm::ModuleDetail do
  subject(:module_detail) do
    FactoryGirl.build(:mdm_module_detail)
  end

  context 'associations' do
    it { should have_many(:actions).class_name('Mdm::ModuleAction').dependent(:destroy) }
    it { should have_many(:archs).class_name('Mdm::ModuleArch').dependent(:destroy) }
    it { should have_many(:authors).class_name('Mdm::ModuleAuthor').dependent(:destroy) }
    it { should have_many(:mixins).class_name('Mdm::ModuleMixin').dependent(:destroy) }
    it { should have_many(:platforms).class_name('Mdm::ModulePlatform').dependent(:destroy) }
    it { should have_many(:refs).class_name('Mdm::ModuleRef').dependent(:destroy) }
    it { should have_many(:targets).class_name('Mdm::ModuleTarget').dependent(:destroy) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:default_target).of_type(:integer) }
      it { should have_db_column(:description).of_type(:text) }
      it { should have_db_column(:disclosure_date).of_type(:datetime)}
      it { should have_db_column(:file).of_type(:text) }
      it { should have_db_column(:fullname).of_type(:text) }
      it { should have_db_column(:license).of_type(:string) }
      it { should have_db_column(:mtime).of_type(:datetime) }
      it { should have_db_column(:mtype).of_type(:string) }
      it { should have_db_column(:name).of_type(:text) }
      it { should have_db_column(:privileged).of_type(:boolean) }
      it { should have_db_column(:rank).of_type(:integer) }
      it { should have_db_column(:ready).of_type(:boolean) }
      it { should have_db_column(:refname).of_type(:text) }
      it { should have_db_column(:stance).of_type(:string) }
    end

    context 'indices' do
      it { should have_db_index(:description) }
      it { should have_db_index(:mtype) }
      it { should have_db_index(:name) }
      it { should have_db_index(:refname) }
    end
  end

  context 'factories' do
    context 'mdm_module_detail' do
      subject(:mdm_module_detail) do
        FactoryGirl.build(:mdm_module_detail)
      end

      it { should be_valid }
    end
  end

  context 'validations' do
    it { should validate_presence_of(:refname) }
  end

  context 'with saved' do
    before(:each) do
      module_detail.save!
    end

    context '#add_action' do
      def add_action
        module_detail.add_action(name)
      end

      let(:name) do
        FactoryGirl.generate :mdm_module_action_name
      end

      it 'should add an Mdm::ModuleAction under the Mdm::ModuleDetail' do
        expect {
          add_action
        }.to change(module_detail.actions, :length).by(1)
      end

      context 'new Mdm::ModuleAction' do
        subject(:module_action) do
          add_action

          module_detail.actions.last
        end

        it { should be_valid }

        its(:name) { should == name }
      end
    end

    context '#add_arch' do
      def add_arch
        module_detail.add_arch(name)
      end

      let(:name) do
        FactoryGirl.generate :mdm_module_arch_name
      end

      it 'should add an Mdm::ModuleArch under the Mdm::ModuleDetail' do
        expect {
          add_arch
        }.to change(module_detail.archs, :length).by(1)
      end

      context 'new Mdm::ModuleArch' do
        subject(:module_arch) do
          add_arch

          module_detail.archs.last
        end

        it { should be_valid }

        its(:name) { should == name }
      end
    end

    context '#add_author' do
      let(:name) do
        FactoryGirl.generate :mdm_module_author_name
      end

      context 'with email' do
        def add_author
          module_detail.add_author(name, email)
        end

        let(:email) do
          FactoryGirl.generate :mdm_module_author_email
        end

        it 'should add an Mdm::ModuleAuthor under the Mdm::ModuleDetail' do
          expect {
            add_author
          }.to change(module_detail.authors, :length).by(1)
        end

        context 'new Mdm::ModuleAuthor' do
          subject(:module_author) do
            add_author

            module_detail.authors.last
          end

          it { should be_valid }

          its(:email) { should == email }
          its(:name) { should == name }
        end
      end

      context 'without email' do
        def add_author
          module_detail.add_author(name)
        end

        it 'should add an Mdm::ModuleAuthor under the Mdm::ModuleDetail' do
          expect {
            add_author
          }.to change(module_detail.authors, :length).by(1)
        end

        context 'new Mdm::ModuleAuthor' do
          subject(:module_author) do
            add_author

            module_detail.authors.last
          end

          it { should be_valid }

          its(:email) { should be_nil }
          its(:name) { should == name }
        end
      end
    end

    context '#add_mixin' do
      def add_mixin
        module_detail.add_mixin(name)
      end

      let(:name) do
        FactoryGirl.generate :mdm_module_mixin_name
      end

      it 'should add an Mdm::ModuleMixin under the Mdm::ModuleDetail' do
        expect {
          add_mixin
        }.to change(module_detail.mixins, :length).by(1)
      end

      context 'new Mdm::ModuleMixin' do
        subject do
          add_mixin

          module_detail.mixins.last
        end

        it { should be_valid }
        its(:name) { should == name }
      end
    end

    context '#add_platform' do
      def add_platform
        module_detail.add_platform(name)
      end

      let(:name) do
        FactoryGirl.generate :mdm_module_platform_name
      end

      it 'should add an Mdm::ModulePlatform under the Mdm::ModuleDetail' do
        expect {
          add_platform
        }.to change(module_detail.platforms, :length).by(1)
      end

      context 'new Mdm::ModulePlatform' do
        subject(:module_platform) do
          add_platform

          module_detail.platforms.last
        end

        it { should be_valid }
        its(:name) { should == name }
      end
    end

    context '#add_ref' do
      def add_ref
        module_detail.add_ref(name)
      end

      let(:name) do
        FactoryGirl.generate :mdm_module_ref_name
      end

      it 'should add an Mdm::ModuleRef under the Mdm::ModuleDetail' do
        expect {
          add_ref
        }.to change(module_detail.refs, :length).by(1)
      end

      context 'new Mdm::ModuleRef' do
        subject(:module_ref) do
          add_ref

          module_detail.refs.last
        end

        it { should be_valid }
        its(:name) { should == name }
      end
    end

    context '#add_target' do
      def add_target
        module_detail.add_target(index, name)
      end

      let(:index) do
        FactoryGirl.generate :mdm_module_target_index
      end

      let(:name) do
        FactoryGirl.generate :mdm_module_target_name
      end

      it 'should add an Mdm::ModuleTarget under the Mdm::ModuleDetail' do
        expect {
          add_target
        }.to change(module_detail.targets, :length).by(1)
      end

      context 'new Mdm::ModuleTarget' do
        subject(:module_target) do
          add_target

          module_detail.targets.last
        end

        it { should be_valid }
        its(:name) { should == name }
      end
    end
  end
end