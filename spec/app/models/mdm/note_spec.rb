require 'spec_helper'

describe Mdm::Note do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'factory' do
    it 'should be valid' do
      note = FactoryGirl.build(:mdm_note)
      note.should be_valid
    end
  end

  context 'database' do

    context 'timestamps'do
      it { should have_db_column(:created_at).of_type(:datetime) }
      it { should have_db_column(:updated_at).of_type(:datetime) }
    end

    context 'columns' do
      it { should have_db_column(:workspace_id).of_type(:integer).with_options(:null => false, :default =>1) }
      it { should have_db_column(:host_id).of_type(:integer) }
      it { should have_db_column(:service_id).of_type(:integer) }
      it { should have_db_column(:vuln_id).of_type(:integer) }
      it { should have_db_column(:ntype).of_type(:string) }
      it { should have_db_column(:critical).of_type(:boolean) }
      it { should have_db_column(:seen).of_type(:boolean) }
      it { should have_db_column(:data).of_type(:text) }
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      note = FactoryGirl.create(:mdm_note)
      expect {
        note.destroy
      }.to_not raise_error
      expect {
        note.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'associations' do
    it { should belong_to(:workspace).class_name('Mdm::Workspace') }
    it { should belong_to(:host).class_name('Mdm::Host') }
    it { should belong_to(:service).class_name('Mdm::Service') }
    it { should belong_to(:vuln).class_name('Mdm::Vuln') }
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