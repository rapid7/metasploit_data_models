require 'spec_helper'

describe MetasploitDataModels::Search::Operation::IPAddress::V4::Single do
  subject(:operation) {
    described_class.new(
        value: formatted_value,
        operator: operator
    )
  }

  let(:formatted_value) {
    '1.2.3.4'
  }

  let(:operator) {
    double(
        'MetasploitDataModels::Search::Operator::IPAddress::Range',
        valid?: true
    )
  }

  context 'CONSTANTS' do
    context 'ADDRESS_REGEXP' do
      subject(:address_regexp) {
        described_class::ADDRESS_REGEXP
      }

      it { should match('0.0.0.0') }
      it { should match('255.255.255.255') }
      it { should_not match('::') }
      it { should_not match('1:2:3:4:5:6:7:8') }
    end

    context 'SEGMENT_REGEXP' do
      subject(:segment_regexp) {
        described_class::SEGMENT_REGEXP
      }

      it { should match('0') }
      it { should match('255') }
      it { should_not match('ffff') }
    end
  end

  context 'validations' do
    context 'errors on #value' do
      subject(:value_errors) {
        operation.errors[:value]
      }

      #
      # lets
      #

      let(:error) {
        I18n.translate!('metasploit.model.errors.models.metasploit_data_models/search/operation/ip_address/v4/single.attributes.value.format')
      }

      #
      # Callbacks
      #

      before(:each) {
        operation.valid?
      }

      context 'with IPv4' do
        # IPAddr handles CIDR and netmask formats, but this class shouldn't, so need to test that CIDR is invalid.
        context 'with CIDR' do
          let(:formatted_value) {
            '1.2.3.4/24'
          }

          it { should include error }
        end

        context 'with single' do
          let(:formatted_value) {
            '1.2.3.4'
          }

          it { should_not include error }
        end
      end

      context 'without IPAddr' do
        let(:formatted_value) {
          'a.b.c.d'
        }

        it { should include error }
      end
    end
  end

  it_should_behave_like 'MetasploitDataModels::Search::Operation::IPAddress::*.match',
                        4 => :single

  context '#value' do
    subject(:value) {
      operation.value
    }

    context 'with nil' do
      let(:formatted_value) {
        nil
      }

      it { should be_nil }
    end

    context 'with IPv4 address' do
      let(:formatted_value) {
        '1.2.3.4'
      }

      it { should be_an IPAddr }
    end

    context 'without IPv4 address' do
      let(:formatted_value) {
        '1:2:3:4:5:6:7:8'
      }

      it 'is the unconverted formatted_value' do
        expect(value).to eq(formatted_value)
      end
    end
  end
end