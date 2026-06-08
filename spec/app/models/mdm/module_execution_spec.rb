RSpec.describe Mdm::ModuleExecution, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'factory' do
    it 'builds a valid record' do
      record = FactoryBot.build(:mdm_module_execution)
      expect(record).to be_valid
    end
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:workspace_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:module_reference_name).of_type(:text).with_options(null: false) }
      it { is_expected.to have_db_column(:module_type).of_type(:text).with_options(null: false) }
      it { is_expected.to have_db_column(:kind).of_type(:text).with_options(null: false, default: 'run') }
      it { is_expected.to have_db_column(:options_snapshot) }
      it { is_expected.to have_db_column(:originating_ui).of_type(:text).with_options(null: false) }
      it { is_expected.to have_db_column(:originating_user_id).of_type(:integer) }
      it { is_expected.to have_db_column(:originating_token_ref).of_type(:text) }
      it { is_expected.to have_db_column(:parent_execution_id).of_type(:integer) }
      it { is_expected.to have_db_column(:started_at).with_options(null: false) }
      it { is_expected.to have_db_column(:ended_at) }
      it { is_expected.to have_db_column(:terminal_status).of_type(:text) }
      it { is_expected.to have_db_column(:failure_reason).of_type(:text) }
      it { is_expected.to have_db_column(:failure_message).of_type(:text) }
      it { is_expected.to have_db_column(:single_entity_failure_count).of_type(:integer).with_options(null: false, default: 0) }
      it { is_expected.to have_db_column(:last_single_entity_errors) }
    end

    context 'indexes' do
      it { is_expected.to have_db_index([:workspace_id, :started_at]) }
      it { is_expected.to have_db_index([:module_reference_name, :started_at]) }
      it { is_expected.to have_db_index([:kind, :originating_ui]) }
    end
  end

  context 'associations' do
    it { is_expected.to belong_to(:workspace).class_name('Mdm::Workspace') }
    it { is_expected.to belong_to(:originating_user).optional.class_name('Mdm::User') }
    it { is_expected.to belong_to(:parent_execution).optional.class_name('Mdm::ModuleExecution') }
    it { is_expected.to have_many(:children).class_name('Mdm::ModuleExecution') }
    it { is_expected.to have_many(:execution_errors).class_name('Mdm::ModuleExecutionError') }
    it { is_expected.to have_many(:events).class_name('Mdm::ModuleExecutionEvent') }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:module_reference_name) }
    it { is_expected.to validate_presence_of(:module_type) }
    it { is_expected.to validate_presence_of(:kind) }
    it { is_expected.to validate_presence_of(:originating_ui) }
    it { is_expected.to validate_presence_of(:started_at) }

    it 'accepts every documented module_type' do
      Mdm::ModuleExecution::MODULE_TYPES.each do |t|
        record = FactoryBot.build(:mdm_module_execution, module_type: t)
        expect(record).to be_valid, "expected #{t.inspect} to be valid"
      end
    end

    it 'rejects an unknown module_type' do
      record = FactoryBot.build(:mdm_module_execution, module_type: 'bogus')
      expect(record).not_to be_valid
    end

    it 'accepts every documented kind' do
      Mdm::ModuleExecution::KINDS.each do |k|
        record = FactoryBot.build(:mdm_module_execution, kind: k)
        expect(record).to be_valid, "expected #{k.inspect} to be valid"
      end
    end

    it 'rejects an unknown kind' do
      record = FactoryBot.build(:mdm_module_execution, kind: 'bogus')
      expect(record).not_to be_valid
    end

    it 'accepts every documented originating_ui' do
      Mdm::ModuleExecution::ORIGINATING_UIS.each do |ui|
        record = FactoryBot.build(:mdm_module_execution, originating_ui: ui)
        expect(record).to be_valid, "expected #{ui.inspect} to be valid"
      end
    end

    it 'rejects an unknown originating_ui' do
      record = FactoryBot.build(:mdm_module_execution, originating_ui: 'bogus')
      expect(record).not_to be_valid
    end

    it 'accepts a NULL terminal_status while ended_at is NULL' do
      record = FactoryBot.build(:mdm_module_execution, terminal_status: nil, ended_at: nil)
      expect(record).to be_valid
    end

    it 'accepts terminal_status = running while ended_at is NULL' do
      record = FactoryBot.build(:mdm_module_execution, terminal_status: 'running', ended_at: nil)
      expect(record).to be_valid
    end

    it 'rejects a non-running terminal_status while ended_at is NULL' do
      record = FactoryBot.build(:mdm_module_execution, terminal_status: 'success', ended_at: nil)
      expect(record).not_to be_valid
      expect(record.errors[:terminal_status]).not_to be_empty
    end

    it 'rejects a NULL terminal_status when ended_at is set' do
      now = Time.now.utc
      record = FactoryBot.build(:mdm_module_execution,
                                terminal_status: nil,
                                started_at: now,
                                ended_at: now)
      expect(record).not_to be_valid
      expect(record.errors[:terminal_status]).not_to be_empty
    end

    it 'rejects terminal_status = running when ended_at is set' do
      now = Time.now.utc
      record = FactoryBot.build(:mdm_module_execution,
                                terminal_status: 'running',
                                started_at: now,
                                ended_at: now)
      expect(record).not_to be_valid
    end

    it 'accepts a terminal status when ended_at is set' do
      now = Time.now.utc
      record = FactoryBot.build(:mdm_module_execution,
                                terminal_status: 'success',
                                started_at: now,
                                ended_at: now + 1)
      expect(record).to be_valid
    end

    it 'rejects ended_at before started_at' do
      now = Time.now.utc
      record = FactoryBot.build(:mdm_module_execution,
                                terminal_status: 'success',
                                started_at: now,
                                ended_at: now - 1)
      expect(record).not_to be_valid
      expect(record.errors[:ended_at]).not_to be_empty
    end

    it 'rejects a negative single_entity_failure_count' do
      record = FactoryBot.build(:mdm_module_execution, single_entity_failure_count: -1)
      expect(record).not_to be_valid
    end
  end

  context 'parent / child executions' do
    it 'links a child to its parent' do
      parent = FactoryBot.create(:mdm_module_execution)
      child  = FactoryBot.create(:mdm_module_execution,
                                 workspace: parent.workspace,
                                 parent_execution: parent)
      expect(parent.children.reload).to include(child)
      expect(child.parent_execution).to eq(parent)
    end

    it 'nullifies parent_execution_id on children when parent is destroyed' do
      parent = FactoryBot.create(:mdm_module_execution)
      child  = FactoryBot.create(:mdm_module_execution,
                                 workspace: parent.workspace,
                                 parent_execution: parent)
      parent.destroy
      expect(child.reload.parent_execution_id).to be_nil
    end
  end

  context 'reverse associations' do
    it 'is reachable from its workspace' do
      record = FactoryBot.create(:mdm_module_execution)
      expect(record.workspace.module_executions).to include(record)
    end

    it 'is reachable from its originating user' do
      user = FactoryBot.create(:mdm_user)
      record = FactoryBot.create(:mdm_module_execution, originating_user: user)
      expect(user.module_executions).to include(record)
    end
  end
end
