require 'spec_helper'

describe MetasploitDataModels::IPAddress::V4::Segment do
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

    context 'REGEXP' do
      subject(:regexp) {
        described_class::REGEXP
      }

      it { should_not match_string_exactly('256') }
      it { should match_string_exactly('255') }
      it { should match_string_exactly('200') }
      it { should match_string_exactly('100') }
      it { should match_string_exactly('10') }
      it { should match_string_exactly('1') }
      it { should_not match_string_exactly('1-2') }
    end
  end
end