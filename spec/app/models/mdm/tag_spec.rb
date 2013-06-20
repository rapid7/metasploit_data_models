require 'spec_helper'
require 'securerandom'

describe Mdm::Tag do

  context 'associations' do
    it { should have_many(:host_tags).class_name('Mdm::HostTag').dependent(:destroy) }
    it { should have_many(:hosts).class_name('Mdm::Host').through(:host_tags) }
    it { should belong_to(:user).class_name('Mdm::User') }
  end

  context 'database' do

    context 'timestamps'do
      it { should have_db_column(:created_at).of_type(:datetime).with_options(:null => false) }
      it { should have_db_column(:updated_at).of_type(:datetime).with_options(:null => false) }
    end

    context 'columns' do
      it { should have_db_column(:user_id).of_type(:integer) }
      it { should have_db_column(:name).of_type(:string) }
      it { should have_db_column(:desc).of_type(:text) }
      it { should have_db_column(:report_summary).of_type(:boolean).with_options(:null => false, :default =>false) }
      it { should have_db_column(:report_detail).of_type(:boolean).with_options(:null => false, :default =>false) }
      it { should have_db_column(:critical).of_type(:boolean).with_options(:null => false, :default =>false) }
    end
  end

  context 'validations' do
    context 'desc'  do
      it 'should not ba valid for a length over 8k' do
        desc = SecureRandom.hex(9001) #over 9000?!
        large_tag = FactoryGirl.build(:mdm_tag, :desc => desc)
        large_tag.should_not be_valid
        large_tag.errors[:desc].should include('desc must be less than 8k.')
      end
    end

    context 'name' do
      it 'must be present' do
        nameless_tag = FactoryGirl.build(:mdm_tag, :name => nil)
        nameless_tag.should_not be_valid
        nameless_tag.errors[:name].should include("can't be blank")
      end

      it 'may only contain alphanumerics, dot, dashes, and underscores' do
        mytag = FactoryGirl.build(:mdm_tag, :name => 'A.1-B_2')
        mytag.should be_valid
        #Test for various bad inputs we should never allow
        mytag = FactoryGirl.build(:mdm_tag, :name => "A'1")
        mytag.should_not be_valid
        mytag.errors[:name].should include('must be alphanumeric, dots, dashes, or underscores')
        mytag = FactoryGirl.build(:mdm_tag, :name => "A;1")
        mytag.should_not be_valid
        mytag.errors[:name].should include('must be alphanumeric, dots, dashes, or underscores')
        mytag = FactoryGirl.build(:mdm_tag, :name => "A%1")
        mytag.should_not be_valid
        mytag.errors[:name].should include('must be alphanumeric, dots, dashes, or underscores')
        mytag = FactoryGirl.build(:mdm_tag, :name => "A=1")
        mytag.should_not be_valid
        mytag.errors[:name].should include('must be alphanumeric, dots, dashes, or underscores')
        mytag = FactoryGirl.build(:mdm_tag, :name => "#A1")
        mytag.should_not be_valid
        mytag.errors[:name].should include('must be alphanumeric, dots, dashes, or underscores')
      end
    end
  end

  context 'factories' do
    context 'mdm_tag' do
      subject(:mdm_tag) do
        FactoryGirl.build(:mdm_tag)
      end

      it { should be_valid }
    end
  end

  context '#to_s' do
    it 'should return the name of the tag as a string' do
      mytag = FactoryGirl.build(:mdm_tag, :name => 'mytag')
      mytag.to_s.should == 'mytag'
    end
  end

  context '#destroy' do
    let!(:tag) do
      FactoryGirl.create(:mdm_tag)
    end

    it 'should successfully destroy the object' do
      expect {
        tag.destroy
      }.to change(Mdm::Tag, :count).by(-1)
    end
  end

end