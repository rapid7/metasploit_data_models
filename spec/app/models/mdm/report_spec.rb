require 'spec_helper'

describe Mdm::Report do

  context 'associations' do
    it { should belong_to(:workspace).class_name('Mdm::Workspace') }
  end

  context 'validations' do
    context 'name' do
      it 'may be blank' do
        blank_name = FactoryGirl.build(:mdm_report, :name => '')
        blank_name.should be_valid
      end

      it 'may contain A-Z, 0-9, space, dot, underscore, or dash' do
        named_report = FactoryGirl.build(:mdm_report, :name => 'A1 B2.C_3-D')
        named_report.should be_valid
      end

      it 'may not contain other characters' do
        invalid_name = FactoryGirl.build(:mdm_report, :name => 'A/1')
        invalid_name.should_not be_valid
        invalid_name.errors[:name].should include('name must consist of A-Z, 0-9, space, dot, underscore, or dash')
        invalid_name = FactoryGirl.build(:mdm_report, :name => '#A1')
        invalid_name.should_not be_valid
        invalid_name.errors[:name].should include('name must consist of A-Z, 0-9, space, dot, underscore, or dash')
        invalid_name = FactoryGirl.build(:mdm_report, :name => 'A,1')
        invalid_name.should_not be_valid
        invalid_name.errors[:name].should include('name must consist of A-Z, 0-9, space, dot, underscore, or dash')
        invalid_name = FactoryGirl.build(:mdm_report, :name => 'A;1')
        invalid_name.should_not be_valid
        invalid_name.errors[:name].should include('name must consist of A-Z, 0-9, space, dot, underscore, or dash')
        invalid_name = FactoryGirl.build(:mdm_report, :name => "A' or '1'='1'")
        invalid_name.should_not be_valid
        invalid_name.errors[:name].should include('name must consist of A-Z, 0-9, space, dot, underscore, or dash')
      end
    end
  end

  context 'scopes' do
    context 'flagged'  do
      it 'should return un-downlaoded reports' do
        flagged_report = FactoryGirl.create(:mdm_report)
        Mdm::Report.flagged.should include(flagged_report)
      end

      it 'should not return reports that have been downloaded' do
        downlaoded_report = FactoryGirl.create(:mdm_report, :downloaded_at => Time.now)
        Mdm::Report.flagged.should_not include(downlaoded_report)
      end
    end
  end

  context 'callbacks' do
    context 'before_destroy' do
      it 'should call #delete_file' do
        myreport =  FactoryGirl.create(:mdm_report)
        myreport.should_receive(:delete_file)
        myreport.destroy
      end
    end
  end

  context 'factory' do
    it 'should be valid' do
      report = FactoryGirl.build(:mdm_report)
      report.should be_valid
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      report = FactoryGirl.create(:mdm_report)
      expect {
        report.destroy
      }.to_not raise_error
      expect {
        report.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'database' do

    context 'timestamps'do
      it { should have_db_column(:created_at).of_type(:datetime).with_options(:null => false) }
      it { should have_db_column(:updated_at).of_type(:datetime).with_options(:null => false) }
      it { should have_db_column(:downloaded_at).of_type(:datetime) }
    end

    context 'columns' do
      it { should have_db_column(:workspace_id).of_type(:integer).with_options(:null => false, :default =>1) }
      it { should have_db_column(:created_by).of_type(:string) }
      it { should have_db_column(:rtype).of_type(:string) }
      it { should have_db_column(:path).of_type(:string) }
      it { should have_db_column(:options).of_type(:text) }
      it { should have_db_column(:name).of_type(:string) }

    end
  end

end