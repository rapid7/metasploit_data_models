shared_examples_for 'Mdm::Attempt' do
  context 'associations' do
    it { should belong_to(:loot).class_name('Mdm::Loot') }
    it { should belong_to(:module_class).class_name('Mdm::Module::Class') }
    it { should belong_to(:vuln).class_name('Mdm::Vuln') }
    it { should belong_to(:session).class_name('Mdm::Session') }
  end

  context 'database' do
    context 'columns' do
      context 'timestamps' do
        it { should have_db_column(:attempted_at).of_type(:datetime) }
      end

      it { should have_db_column(:exploited).of_type(:boolean) }
      it { should have_db_column(:fail_detail).of_type(:text) }
      it { should have_db_column(:fail_reason).of_type(:string) }
      it { should have_db_column(:loot_id).of_type(:integer) }
      it { should have_db_column(:module).of_type(:text) }
      it { should have_db_column(:module_class_id).of_type(:integer) }
      it { should have_db_column(:session_id).of_type(:integer) }
      it { should have_db_column(:username).of_type(:string) }
      it { should have_db_column(:vuln_id).of_type(:integer) }
    end

    context 'indices' do
      it { should have_db_index(:module_class_id) }
    end
  end

  context '#module' do
    subject(:attempt_module) do
      attempt.module
    end

    it 'is deprecated' do
      expect(ActiveSupport::Deprecation).to receive(:warn).with(/#module is deprecated/)

      attempt_module
    end

    context 'with attribute set' do
      #
      # lets
      #

      let(:expected) do
        'module/class/full/name'
      end

      #
      # Callbacks
      #

      before(:each) do
        attempt.module = expected
      end

      it 'reads attribute' do
        expect(attempt_module).to eq(expected)
      end
    end
  end

  context '#module=' do
    subject(:written_module) do
      attempt.module = full_name
    end

    let(:full_name) do
      'module/class/full/name'
    end

    it 'is deprecated' do
      expect(ActiveSupport::Deprecation).to receive(:warn).with(/#module= is deprecated/)

      written_module
    end

    it 'can be read back with #module' do
      written_module

      expect(attempt.module).to eq(full_name)
    end
  end
end