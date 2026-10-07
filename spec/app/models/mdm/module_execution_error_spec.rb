RSpec.describe Mdm::ModuleExecutionError, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'factory' do
    it 'builds a valid record' do
      record = FactoryBot.build(:mdm_module_execution_error)
      expect(record).to be_valid
    end
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:module_execution_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:exception_class).of_type(:text) }
      it { is_expected.to have_db_column(:message).of_type(:text) }
      it { is_expected.to have_db_column(:backtrace).of_type(:text) }
      it { is_expected.to have_db_column(:lifecycle_phase).of_type(:text).with_options(null: false) }
      it { is_expected.to have_db_column(:failure_reason).of_type(:text) }
      it { is_expected.to have_db_column(:occurred_at).with_options(null: false) }
      it { is_expected.to have_db_column(:created_at).with_options(null: false) }
    end

    context 'indexes' do
      it { is_expected.to have_db_index([:module_execution_id, :occurred_at]) }
    end
  end

  context 'associations' do
    it { is_expected.to belong_to(:module_execution).class_name('Mdm::ModuleExecution') }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:lifecycle_phase) }
    it { is_expected.to validate_presence_of(:occurred_at) }

    it 'accepts every documented lifecycle phase' do
      Mdm::ModuleExecutionError::LIFECYCLE_PHASES.each do |phase|
        record = FactoryBot.build(:mdm_module_execution_error, lifecycle_phase: phase)
        expect(record).to be_valid, "expected #{phase.inspect} to be valid"
      end
    end

    it 'rejects an unknown lifecycle phase' do
      record = FactoryBot.build(:mdm_module_execution_error, lifecycle_phase: 'bogus')
      expect(record).not_to be_valid
      expect(record.errors[:lifecycle_phase]).not_to be_empty
    end
  end

  context 'cascade delete' do
    it 'is destroyed when the parent module_execution is destroyed' do
      record = FactoryBot.create(:mdm_module_execution_error)
      execution = record.module_execution
      expect { execution.destroy }
        .to change { Mdm::ModuleExecutionError.where(id: record.id).count }.from(1).to(0)
    end
  end
end
