shared_examples_for 'MetasploitDataModels::Batch::Root' do
  let(:error) do
    ActiveRecord::RecordNotUnique.new("not unique", original_exception)
  end

  let(:original_exception) do
    double('Original Exception')
  end

  context '#batched_save' do
    subject(:batched_save) do
      base_instance.batched_save
    end

    it 'should call MetasploitDataModels::Batch.batch' do
      MetasploitDataModels::Batch.should_receive(:batch)

      batched_save
    end

    it 'should call #recoverable_save' do
      base_instance.should_receive(:recoverable_save)

      batched_save
    end

    context 'with ActiveRecord::RecordNotUnique raised' do
      before(:each) do
        base_instance.should_receive(:recoverable_save).and_raise(error)
      end

      it 'should call recoverable_save outside batch mode' do
        base_instance.should_receive(:recoverable_save) {
          MetasploitDataModels::Batch.should_not be_batched
        }

        batched_save
      end
    end
  end

  context '#recoverable_save' do
    subject(:recoverable_save) do
      base_instance.recoverable_save
    end

    it 'should create a new transaction' do
      base_instance.stub(:save)

      ActiveRecord::Base.should_receive(:transaction).with(
          hash_including(
              requires_new: true
          )
      )

      recoverable_save
    end

    context 'inside another transaction' do
      context 'with an exception raised by save' do
        before(:each) do
          base_instance.should_receive(:save).and_raise(error)
        end

        it 'should not kill outer transaction' do
          ActiveRecord::Base.transaction do
            begin
              recoverable_save
            rescue ActiveRecord::RecordNotUnique
              expect {
                Mdm::Architecture.count
              }.should_not raise_error
            end
          end
        end
      end
    end
  end
end