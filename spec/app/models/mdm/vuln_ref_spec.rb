RSpec.describe Mdm::VulnRef, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'factories' do
    context 'mdm_vuln_ref' do
      subject(:mdm_vuln_ref) do
        FactoryGirl.build(:mdm_vuln_ref)
      end

      it { should be_valid }
    end
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:id).of_type(:integer) }
      it { should have_db_column(:ref_id).of_type(:integer) }
      it { should have_db_column(:vuln_id).of_type(:integer) }
    end
  end

  context 'associations' do
    it { should belong_to(:vuln).class_name('Mdm::Vuln') }
    it { should belong_to(:ref).class_name('Mdm::Ref') }
  end

  context 'factory' do
    it 'should be valid' do
      vuln_ref = FactoryGirl.build(:mdm_vuln_ref)
      vuln_ref.should be_valid
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      vuln_ref = FactoryGirl.create(:mdm_vuln_ref)
      expect {
        vuln_ref.destroy
      }.to_not raise_error
      expect {
        vuln_ref.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
end