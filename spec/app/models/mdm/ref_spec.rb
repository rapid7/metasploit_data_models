require 'spec_helper'

describe Mdm::Ref do
  context 'associations' do
    # shoulda matchers don't have support for :primary_key option, so need to
    # test this association manually
    context 'module_refs' do
      context 'with Mdm::Module::Refs' do
        context 'with same name' do
          let(:name) do
            FactoryGirl.generate :mdm_ref_name
          end

          let!(:module_ref) do
            FactoryGirl.create(:mdm_module_ref, :name => name)
          end

          let!(:ref) do
            FactoryGirl.create(:mdm_ref, :name => name)
          end

          it 'should have module_refs in assocation' do
            ref.module_refs.should =~ [module_ref]
          end
        end
      end
    end

    # @todo https://www.pivotaltracker.com/story/show/48915453
    it { should have_many(:vulns_refs).class_name('Mdm::VulnRef') }
    it { should have_many(:vulns).class_name('Mdm::Vuln').through(:vulns_refs) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:name).of_type(:string) }
      it { should have_db_column(:ref_id).of_type(:integer) }

      context 'timestamps' do
        it { should have_db_column(:created_at).of_type(:datetime) }
        it { should have_db_column(:updated_at).of_type(:datetime) }
      end
    end

    context 'indices' do
      it { should have_db_index(:name) }
    end
  end

  context 'factories' do
    context 'mdm_ref' do
      subject(:mdm_ref) do
        FactoryGirl.build :mdm_ref
      end

      it { should be_valid }
    end
  end

  context 'mass assignment security' do
    it { should allow_mass_assignment_of(:name) }
  end
end