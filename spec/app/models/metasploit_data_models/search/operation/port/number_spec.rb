RSpec.describe MetasploitDataModels::Search::Operation::Port::Number, type: :model do
  context 'CONSTANTS' do
    context 'BITS' do
      subject(:bits) {
        described_class::BITS
      }

      it { should == 16 }
    end

    context 'MAXIMUM' do
      subject(:maxium) {
        described_class::MAXIMUM
      }

      it { should == 65535 }
    end

    context 'MINIMUM' do
      subject(:minimum) {
        described_class::MINIMUM
      }

      it { should == 0 }
    end

    context 'RANGE' do
      subject(:range) {
        described_class::RANGE
      }

      it { should == (0..65535) }
    end
  end

  context 'validations' do
    it { should ensure_inclusion_of(:value).in_range(described_class::RANGE) }
  end
end