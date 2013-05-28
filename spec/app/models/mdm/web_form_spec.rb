require 'spec_helper'

describe Mdm::WebForm do

  context 'associations' do
    it { should belong_to(:web_site).class_name('Mdm::WebSite') }
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