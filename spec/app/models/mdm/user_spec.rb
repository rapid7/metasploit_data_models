require 'spec_helper'

describe Mdm::User do

  context 'associations' do
    it { should have_many(:owned_workspaces).class_name('Mdm::Workspace') }
    it { should have_many(:tags).class_name('Mdm::Tag') }
    it { should have_and_belong_to_many(:workspaces).class_name('Mdm::Workspace') }
  end

  context 'database' do

    context 'timestamps'do
      it { should have_db_column(:created_at).of_type(:datetime).with_options(:null => false) }
      it { should have_db_column(:updated_at).of_type(:datetime).with_options(:null => false) }
    end

    context 'columns' do
      it { should have_db_column(:username).of_type(:string) }
      it { should have_db_column(:crypted_password).of_type(:string) }
      it { should have_db_column(:password_salt).of_type(:string) }
      it { should have_db_column(:persistence_token).of_type(:string) }
      it { should have_db_column(:fullname).of_type(:string) }
      it { should have_db_column(:email).of_type(:string) }
      it { should have_db_column(:phone).of_type(:string) }
      it { should have_db_column(:company).of_type(:string) }
      it { should have_db_column(:prefs).of_type(:string) }
      it { should have_db_column(:admin).of_type(:boolean).with_options(:null => false, :default =>true) }
    end
  end

  context 'factory' do
    it 'should be valid' do
      user = FactoryGirl.build(:mdm_user)
      user.should be_valid
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      user = FactoryGirl.create(:mdm_user)
      expect {
        user.destroy
      }.to_not raise_error
      expect {
        user.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

end