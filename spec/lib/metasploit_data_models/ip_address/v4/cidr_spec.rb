require 'spec_helper'

describe MetasploitDataModels::IPAddress::V4::CIDR do
  context 'CONSTANTS' do
    context 'REGEXP' do
      subject(:regexp) {
        described_class::REGEXP
      }

      it 'matches IPv4 address with prefix length <= 32' do
        expect(regexp).to match_string_exactly('1.2.3.4/32')
      end

      it 'does not match IPv4 address with prefix length > 32' do
        expect(regexp).not_to match_string_exactly('1.2.3.4/33')
      end

      it 'does not match IPv4 address' do
        expect(regexp).not_to match('1.2.3.4')
      end
    end
  end
end