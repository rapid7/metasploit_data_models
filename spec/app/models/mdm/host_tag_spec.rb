require 'spec_helper'

describe Mdm::HostTag do

  context 'associations' do
    it { should belong_to(:host).class_name('Mdm::Host') }
    it { should belong_to(:tag).class_name('Mdm::Tag') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:host_id).of_type(:integer) }
      it { should have_db_column(:tag_id).of_type(:integer) }
    end
  end

  context 'factories' do
    context 'mdm_host_tag' do
      subject(:mdm_host_tag) do
        FactoryGirl.build(:mdm_host_tag)
      end

      it { should be_valid }
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      host_tag = FactoryGirl.create(:mdm_host_tag)
      expect {
        host_tag.destroy
      }.to_not raise_error
      expect {
        host_tag.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

end