require 'spec_helper'

describe Mdm::ReportTemplate do

  context 'associations' do
    it { should belong_to(:workspace).class_name('Mdm::Workspace') }
  end

  context 'callbacks' do
    context 'before_destroy' do
      it 'should call #delete_file' do
        report_template = FactoryGirl.create(:mdm_report_template)
        report_template.should_receive(:delete_file)
        report_template.destroy
      end
    end
  end

  context 'factory' do
    it 'should be valid' do
      report_template = FactoryGirl.build(:mdm_report_template)
      report_template.should be_valid
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      report_template = FactoryGirl.create(:mdm_report_template)
      expect {
        report_template.destroy
      }.to_not raise_error
      expect {
        report_template.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end