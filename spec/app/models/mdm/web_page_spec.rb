require 'spec_helper'

describe Mdm::WebPage do

  context 'associations' do
    it { should belong_to(:web_site).class_name('Mdm::WebSite') }
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