require 'spec_helper'

describe MetasploitDataModels::IPAddress::V4 do
  context 'CONSTANTS' do
    context 'REGEXP' do
      subject(:regexp) {
        described_class::REGEXP
      }

      it 'does not match an IPv4 address range' do
        expect(regexp).not_to match_string_exactly('1.1.1.1-2.2.2.2')
      end

      it 'matches an IPv4 address' do
        expect(regexp).to match_string_exactly('1.1.1.1')
      end
    end
  end
end