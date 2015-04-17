require 'spec_helper'

describe Mdm::WebForm do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { should belong_to(:web_site).class_name('Mdm::WebSite') }
  end

  context 'database' do

    context 'timestamps'do
      it { should have_db_column(:created_at).of_type(:datetime)}
      it { should have_db_column(:updated_at).of_type(:datetime)}
    end

    context 'columns' do
      it { should have_db_column(:web_site_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:path).of_type(:text) }
      it { should have_db_column(:method).of_type(:string) }
      it { should have_db_column(:params).of_type(:text) }
      it { should have_db_column(:query).of_type(:text) }
    end

    context 'indices' do
      it { should have_db_index(:path) }
    end
  end

  context 'factory' do
    it 'should be valid' do
      web_form = FactoryGirl.build(:mdm_web_form)
      web_form.should be_valid
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      web_form = FactoryGirl.create(:mdm_web_form)
      expect {
        web_form.destroy
      }.to_not raise_error
      expect {
        web_form.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end