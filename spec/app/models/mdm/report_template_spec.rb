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
end