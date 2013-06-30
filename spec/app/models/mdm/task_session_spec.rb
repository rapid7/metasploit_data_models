require 'spec_helper'

describe Mdm::TaskSession do
  context 'associations' do
    it { should belong_to(:session).class_name('Mdm::Session') }
    it { should belong_to(:task).class_name('Mdm::Task') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:session_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:task_id).of_type(:integer).with_options(:null => false) }

      context 'timestamps' do
        it { should have_db_column(:created_at).of_type(:datetime).with_options(:null => false) }
        it { should have_db_column(:updated_at).of_type(:datetime).with_options(:null => false) }
      end
    end

    context 'indices' do
      it { should have_db_index([:task_id, :session_id])}
    end
  end

  context 'factories' do
    context 'mdm_task_session' do
      subject(:mdm_task_session) do
        FactoryGirl.build(:mdm_task_session)
      end

      it { should be_valid }
    end
  end

  context 'validations' do
    it { should validate_presence_of :session }

    it 'should not allow duplicate associations' do
      session = FactoryGirl.build(:mdm_session)
      task = FactoryGirl.build(:mdm_task)
      FactoryGirl.create(
          :mdm_task_session,
          :session => session,
          :task => task
      )
      task_session2 = FactoryGirl.build(
          :mdm_task_session,
          :session => session,
          :task => task
      )
      task_session2.should_not be_valid
    end

    it { should validate_presence_of :task }
  end
end