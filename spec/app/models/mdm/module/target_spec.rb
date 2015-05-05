describe Mdm::Module::Target, type: :model do

  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { should belong_to(:detail).class_name('Mdm::Module::Detail') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:detail_id).of_type(:integer) }
      it { should have_db_column(:index).of_type(:integer) }
      it { should have_db_column(:name).of_type(:text) }
    end

    context 'indices' do
      it { should have_db_index(:detail_id) }
    end
  end

  context 'factories' do
    context 'mdm_module_target' do
      subject(:mdm_module_target) do
        FactoryGirl.build :mdm_module_target
      end

      it { should be_valid }
    end
  end

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of(:detail_id) }
    it { should allow_mass_assignment_of(:index) }
    it { should allow_mass_assignment_of(:name) }
  end

  context 'validations' do
    it { should validate_presence_of(:detail) }
    it { should validate_presence_of(:index) }
    it { should validate_presence_of(:name) }
  end
end