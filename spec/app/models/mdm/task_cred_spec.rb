require 'spec_helper'

describe Mdm::TaskCred do
  context 'associations' do
    it { should belong_to(:cred).class_name('Mdm::Cred') }
    it { should belong_to(:task).class_name('Mdm::Task') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:cred_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:task_id).of_type(:integer).with_options(:null => false) }

      context 'timestamps' do
        it { should have_db_column(:created_at).of_type(:datetime).with_options(:null => false) }
        it { should have_db_column(:updated_at).of_type(:datetime).with_options(:null => false) }
      end
    end

    context 'indices' do
      it { should have_db_index([:task_id, :cred_id]).unique(true) }
    end
  end

  context 'factories' do
    context 'mdm_task_cred' do
      subject(:mdm_task_cred) do
        FactoryGirl.build(:mdm_task_cred)
      end

      it { should be_valid }
    end
  end

  context 'validations' do
    it { should validate_presence_of :cred }

    # Can't use validate_uniqueness_of(:cred_id).scoped_to(:task_id) because it will attempt to
    # INSERT with NULL task_id, which is invalid.
    context 'validate uniqueness of cred_id scoped to task_id' do
      let(:existing_cred) do
        FactoryGirl.create(:mdm_cred)
      end

      let(:existing_task) do
        FactoryGirl.create(:mdm_task)
      end

      let!(:existing_task_cred) do
        FactoryGirl.create(
            :mdm_task_cred,
            :cred => existing_cred,
            :task => existing_task
        )
      end

      context 'with same task_id' do
        subject(:new_task_cred) do
          FactoryGirl.build(
              :mdm_task_cred,
              :cred => existing_cred,
              :task => existing_task
          )
        end

        it { should_not be_valid }

        it 'should record error on cred_id' do
          new_task_cred.valid?

          new_task_cred.errors[:cred_id].should include('has already been taken')
        end
      end

      context 'without same task_id' do
        subject(:new_task_cred) do
          FactoryGirl.build(
              :mdm_task_cred,
              :cred => existing_cred,
              :task => new_task
          )
        end

        let(:new_task) do
          FactoryGirl.create :mdm_task
        end

        it { should be_valid }
      end
    end

    it { should validate_presence_of :task }
  end
end