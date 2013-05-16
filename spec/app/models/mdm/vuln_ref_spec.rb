require 'spec_helper'

describe Mdm::VulnRef do
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
  
end