require 'spec_helper'

describe MetasploitDataModels::Batch do
  context 'CONSTANTS' do
    context 'THREAD_LOCAL_VARIABLE_NAME' do
      subject(:thread_local_variable_name) do
        described_class::THREAD_LOCAL_VARIABLE_NAME
      end

      it { should == :metasploit_data_models_batch }
    end
  end

  context 'batch' do
    def batch(&block)
      described_class.batch(&block)
    end

    around(:each) do |example|
      before = Thread.current[:metasploit_data_models_batch]

      example.run

      Thread.current[:metasploit_data_models_batch] = before
    end

    context 'inside block' do
      it 'should have batched? true' do
        batch do
          described_class.should be_batched
        end
      end

      context 'with error' do
        it 'should restore thread local variable' do
          before = double('before')
          Thread.current[described_class::THREAD_LOCAL_VARIABLE_NAME] = before

          expect {
            batch do
              raise
            end
          }.to raise_error

          Thread.current[described_class::THREAD_LOCAL_VARIABLE_NAME].should == before
        end
      end

      context 'without error' do
        it 'should restore thread local variable' do
          before = double('before')
          Thread.current[described_class::THREAD_LOCAL_VARIABLE_NAME] = before

          expect {
            batch {}
          }.to_not raise_error

          Thread.current[described_class::THREAD_LOCAL_VARIABLE_NAME].should == before
        end
      end
    end
  end

  context 'batched?' do
    subject(:batched?) do
      described_class.batched?
    end

    context 'without calling batch' do
      it { should be_false }

      it 'should convert thread local variable to boolean' do
        Thread.current[described_class::THREAD_LOCAL_VARIABLE_NAME].should_not == false
      end
    end
  end
end