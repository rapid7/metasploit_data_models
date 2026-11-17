RSpec.describe MetasploitDataModels do
  context 'CONSTANTS' do
    context 'VERSION' do
      subject(:version) {
        described_class::VERSION
      }

      it 'is MetasploitDataModels::VERSION' do
        expect(version).to eq(MetasploitDataModels::VERSION)
      end
    end
  end
end
