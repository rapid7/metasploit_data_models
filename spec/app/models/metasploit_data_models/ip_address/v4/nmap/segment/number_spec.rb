require 'spec_helper'

describe MetasploitDataModels::IPAddress::V4::NMAP::Segment::Number do
  subject(:number) {
    described_class.new(
        value: formatted_value
    )
  }

  let(:formatted_value) {
    nil
  }

  context 'CONSTANTS' do
    context 'BITS' do
      subject(:bits) {
        described_class::BITS
      }

      it { should == 8 }
    end

    context 'MAXIMUM' do
      subject(:maximum) {
        described_class::MAXIMUM
      }

      it { should == 255 }
    end

    context 'MINIMUM' do
      subject(:MINIMUM) {
        described_class::MINIMUM
      }

      it { should == 0 }
    end
  end

  context 'validations' do
    it { should validate_numericality_of(:value).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(255).only_integer }
  end

  it 'can be used in a Range' do
    expect {
      Range.new(number, number)
    }.not_to raise_error
  end

  context '#<=>' do
    subject(:compare) {
      number <=> other
    }

    let(:other) {
      double('Other')
    }

    it 'compares #values' do
      other_value = double('other.value')

      expect(other).to receive(:value).and_return(other_value)
      expect(number.value).to receive(:<=>).with(other_value)

      compare
    end
  end

  context '#succ' do
    subject(:succ) {
      number.succ
    }

    context '#value' do
      context 'with nil' do
        let(:formatted_value) {
          nil
        }

        specify {
          expect(succ).not_to raise_error
        }
      end

      context 'with number' do
        let(:formatted_value) {
          value.to_s
        }

        let(:value) {
          1
        }

        it { should be_a described_class }

        context 'succ.value' do
          it 'is succ of #value' do
            expect(succ.value).to eq(value.succ)
          end
        end
      end

      context 'without number' do
        let(:formatted_value) {
          'a'
        }

        it { should be_a described_class }

        context 'succ.value' do
          it 'is succ of #value' do
            expect(succ.value).to eq(number.value.succ)
          end
        end
      end
    end
  end

  context '#to_s' do
    subject(:to_s) {
      number.to_s
    }

    #
    # let
    #

    let(:value) {
      double('#value')
    }

    #
    # Callbacks
    #

    before(:each) do
      allow(number).to receive(:value).and_return(value)
    end

    it 'delegates to #value' do
      expect(value).to receive(:to_s)

      to_s
    end
  end

  context '#value' do
    subject(:value) do
      number.value
    end

    context 'with Integer' do
      let(:formatted_value) do
        1
      end

      it 'should pass through Integer' do
        value.should == formatted_value
      end
    end

    context 'with Integer#to_s' do
      let(:formatted_value) do
        integer.to_s
      end

      let(:integer) do
        1
      end

      it 'should convert String to Integer' do
        value.should == integer
      end
    end

    context 'with mix text and numerals' do
      let(:formatted_value) do
        "#{integer}mix"
      end

      let(:integer) do
        123
      end

      it 'should not extract the number' do
        value.should_not == integer
      end

      it 'should pass through the full value' do
        value.should == formatted_value
      end
    end

    context 'with Float' do
      let(:formatted_value) do
        0.1
      end

      it 'should not truncate Float to Integer' do
        value.should_not == formatted_value.to_i
      end

      it 'should pass through Float' do
        value.should == formatted_value
      end
    end
  end
end