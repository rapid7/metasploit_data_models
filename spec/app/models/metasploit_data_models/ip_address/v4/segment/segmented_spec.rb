require 'spec_helper'

describe MetasploitDataModels::IPAddress::V4::Segmented do
  context 'CONSTANTS' do
    context 'SEGMENT_COUNT' do
      subject(:segment_count) {
        described_class::SEGMENT_COUNT
      }

      it { should == 4 }
    end

    context 'SEPARATOR' do
      subject(:separator) {
        described_class::SEPARATOR
      }

      it { should == '.' }
    end
  end

  context 'segment_count' do
    subject(:segment_count) {
      described_class.segment_count
    }

    it { should == 4 }
  end
end