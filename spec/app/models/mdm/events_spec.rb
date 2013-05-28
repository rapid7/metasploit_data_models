require 'spec_helper'

describe Mdm::Event do

  context 'associations' do
    it { should belong_to(:host).class_name('Mdm::Host') }
    it { should belong_to(:workspace).class_name('Mdm::Workspace') }
  end

  context '#destroy' do
    it 'should successfully destroy the object and all dependent objects' do
      event = FactoryGirl.create(:mdm_event)
      expect {
        event.destroy
      }.to_not raise_error
      expect {
        event.reload
      }.to raise_error(ActiveRecord::RecordNotFound)

    end
  end

  context 'scopes' do
    context 'flagged' do
      it 'should exclude non-critical events' do
        flagged_event = FactoryGirl.create(:mdm_event, :name => 'flagme', :critical => true, :seen => false)
        non_critical_event = FactoryGirl.create(:mdm_event, :name => 'dontflagmebro', :critical => false, :seen => false)
        flagged_set = Mdm::Event.flagged
        flagged_set.should include(flagged_event)
        flagged_set.should_not include(non_critical_event)
      end

      it 'should exclude seen events' do
        flagged_event = FactoryGirl.create(:mdm_event, :name => 'flagme', :critical => true, :seen => false)
        non_critical_event = FactoryGirl.create(:mdm_event, :name => 'dontflagmebro', :critical => false, :seen => true)
        flagged_set = Mdm::Event.flagged
        flagged_set.should include(flagged_event)
        flagged_set.should_not include(non_critical_event)
      end
    end

    context 'module_run' do
      it 'should only return module_run events' do
        flagged_event = FactoryGirl.create(:mdm_event, :name => 'module_run')
        non_critical_event = FactoryGirl.create(:mdm_event, :name => 'dontflagmebro')
        flagged_set = Mdm::Event.module_run
        flagged_set.should include(flagged_event)
        flagged_set.should_not include(non_critical_event)
      end
    end
  end

  context 'validations' do
    it 'should require name' do
      unnamed_event = FactoryGirl.build(:mdm_event, :name => nil)
      unnamed_event.should_not be_valid
      unnamed_event.errors[:name].should include("can't be blank")
    end
  end

  context 'factory' do
    it 'should be valid' do
      event = FactoryGirl.build(:mdm_event)
      event.should be_valid
    end
  end

end