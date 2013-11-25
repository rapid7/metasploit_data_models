shared_context 'MetasploitDataModels::Batch.batch' do
  around(:each) do |example|
    MetasploitDataModels::Batch.batch do
      example.run
    end
  end
end