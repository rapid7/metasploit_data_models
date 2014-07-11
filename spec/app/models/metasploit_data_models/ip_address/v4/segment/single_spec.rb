require 'spec_helper'

describe MetasploitDataModels::IPAddress::V4::Segment::Single do
  subject(:single) {
    described_class.new(
        value: formatted_value
    )
  }

  let(:formatted_value) {
    nil
  }

  context 'validations' do
    it { should validate_numericality_of(:value).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(255).only_integer }
  end

  it 'can be used in a Range' do
    expect {
      Range.new(single, single)
    }.not_to raise_error
  end

  context 'match_regexp' do
    subject(:match_regexp) {
      described_class.match_regexp
    }

    it 'matches segment number' do
      expect(match_regexp).to match('255')
    end

    it 'does not match segment range' do
      expect(match_regexp).not_to match('0-225')
    end
  end

  context '#<=>' do
    subject(:compare) {
      single <=> other
    }

    let(:other) {
      double('Other')
    }

    it 'compares #values' do
      other_value = double('other.value')

      expect(other).to receive(:value).and_return(other_value)
      expect(single.value).to receive(:<=>).with(other_value)

      compare
    end
  end

  context '#succ' do
    subject(:succ) {
      single.succ
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
            expect(succ.value).to eq(single.value.succ)
          end
        end
      end
    end
  end

  context '#to_s' do
    subject(:to_s) {
      single.to_s
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
      allow(single).to receive(:value).and_return(value)
    end

    it 'delegates to #value' do
      expect(value).to receive(:to_s)

      to_s
    end
  end

  context '#value' do
    subject(:value) do
      single.value
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