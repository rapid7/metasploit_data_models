require 'spec_helper'

describe Mdm::Note do

  context 'factory' do
    it 'should be valid' do
      note = FactoryGirl.build(:mdm_note)
      note.should be_valid
    end
  end

  context 'associations' do
    it { should belong_to(:workspace).class_name('Mdm::Workspace') }
    it { should belong_to(:host).class_name('Mdm::Host') }
    it { should belong_to(:service).class_name('Mdm::Service') }
  end

  context 'scopes' do
    context 'flagged' do
      it 'should exclude non-critical note' do
        flagged_note = FactoryGirl.create(:mdm_note, :critical => true, :seen => false)
        non_critical_note = FactoryGirl.create(:mdm_note, :critical => false, :seen => false)
        flagged_set = Mdm::Note.flagged
        flagged_set.should include(flagged_note)
        flagged_set.should_not include(non_critical_note)
      end

      it 'should exclude seen notes' do
        flagged_note = FactoryGirl.create(:mdm_note, :critical => true, :seen => false)
        non_critical_note = FactoryGirl.create(:mdm_note, :critical => false, :seen => true)
        flagged_set = Mdm::Note.flagged
        flagged_set.should include(flagged_note)
        flagged_set.should_not include(non_critical_note)
      end
    end

    context 'visible' do
      it 'should only include visible notes' do
        flagged_note = FactoryGirl.create(:mdm_note, :ntype => 'flag.me', :critical => true, :seen => false)
        webform_note = FactoryGirl.create(:mdm_note, :ntype => 'web.form', :critical => true, :seen => false)
        visible_set = Mdm::Note.visible
        visible_set.should include(flagged_note)
        visible_set.should_not include(webform_note)
      end
    end

    context 'search' do
      it 'should match on ntype' do
        flagged_note = FactoryGirl.create(:mdm_note, :ntype => 'flag.me', :critical => true, :seen => false)
        Mdm::Note.search('flag.me').should include(flagged_note)
      end
    end
  end
end