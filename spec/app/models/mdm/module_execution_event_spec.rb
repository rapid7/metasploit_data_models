RSpec.describe Mdm::ModuleExecutionEvent, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'factory' do
    it 'builds a valid record' do
      record = FactoryBot.build(:mdm_module_execution_event)
      expect(record).to be_valid
    end
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:module_execution_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:name).of_type(:text).with_options(null: false) }
      it { is_expected.to have_db_column(:payload) }
      it { is_expected.to have_db_column(:occurred_at).with_options(null: false) }
      it { is_expected.to have_db_column(:created_at).with_options(null: false) }
    end

    context 'indexes' do
      it { is_expected.to have_db_index([:module_execution_id, :occurred_at]) }
      it { is_expected.to have_db_index([:name, :occurred_at]) }
    end
  end

  context 'associations' do
    it { is_expected.to belong_to(:module_execution).class_name('Mdm::ModuleExecution') }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:occurred_at) }
  end

  context 'cascade delete' do
    it 'is destroyed when the parent module_execution is destroyed' do
      record = FactoryBot.create(:mdm_module_execution_event)
      execution = record.module_execution
      expect { execution.destroy }
        .to change { Mdm::ModuleExecutionEvent.where(id: record.id).count }.from(1).to(0)
    end
  end
end
