require 'spec_helper'

describe Mdm::WebPage do

  context 'associations' do
    it { should belong_to(:web_site).class_name('Mdm::WebSite') }
  end

  context 'database' do

    context 'timestamps'do
      it { should have_db_column(:created_at).of_type(:datetime).with_options(:null => false) }
      it { should have_db_column(:updated_at).of_type(:datetime).with_options(:null => false) }
      it { should have_db_column(:mtime).of_type(:datetime) }
    end

    context 'columns' do
      it { should have_db_column(:web_site_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:path).of_type(:text) }
      it { should have_db_column(:query).of_type(:text) }
      it { should have_db_column(:code).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:cookie).of_type(:text) }
      it { should have_db_column(:auth).of_type(:text) }
      it { should have_db_column(:ctype).of_type(:text) }
      it { should have_db_column(:location).of_type(:text) }
      it { should have_db_column(:headers).of_type(:text) }
      it { should have_db_column(:body).of_type(:binary) }
      it { should have_db_column(:request).of_type(:binary) }
    end

    context 'indices' do
      it { should have_db_index(:path) }
      it { should have_db_index(:query) }
    end
  end

  context 'factory' do
    it 'should be valid' do
      web_page = FactoryGirl.build(:mdm_web_page)
      web_page.should be_valid
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      web_page = FactoryGirl.create(:mdm_web_page)
      expect {
        web_page.destroy
      }.to_not raise_error
      expect {
        web_page.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end