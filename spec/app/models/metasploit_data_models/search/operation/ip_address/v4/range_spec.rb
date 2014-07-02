require 'spec_helper'

describe MetasploitDataModels::Search::Operation::IPAddress::V4::Range do
  subject(:operation) {
    described_class.new(
        value: formatted_value,
        operator: operator
    )
  }

  let(:formatted_value) {
    '1.2.3.4-5.6.7.8'
  }

  let(:operator) {
    double(
        'MetasploitDataModels::Search::Operator::IPAddress::Range',
        valid?: true
    )
  }

  context 'CONSTANTS' do
    context 'RANGE_REGEXP' do
      subject(:range_regexp) {
        described_class::RANGE_REGEXP
      }

      it { should_not match('1.2.3.4') }
      it { should match('1.2.3.4-5.6.7.8') }

      context 'groups' do
        subject(:groups) {
          range_regexp.match("#{range_begin}-#{range_end}")
        }

        let(:range_begin) {
          '1.2.3.4'
        }

        let(:range_end) {
          '5.6.7.8'
        }

        context ':begin' do
          subject(:begin_group) {
            groups[:begin]
          }

          it 'is first IP address' do
            expect(begin_group).to eq(range_begin)
          end
        end

        context ':end' do
          subject(:end_group) {
            groups[:end]
          }

          it 'is last IP address' do
            expect(end_group).to eq(range_end)
          end
        end
      end
    end
  end

  context 'validations' do
    before(:each) do
      operation.valid?
    end

    context 'errors on #value' do
      subject(:value_errors) {
        operation.errors[:value]
      }

      context 'with Range' do
        let(:operation) {
          super().tap { |operation|
            allow(operation).to receive(:value).and_return(range)
          }
        }

        let(:range) {
          Range.new(range_begin, range_end)
        }

        let(:range_begin) {
          IPAddr.new('1.2.3.4')
        }

        let(:range_end) {
          IPAddr.new('5.6.7.8')
        }

        context 'Range#begin' do
          let(:error) {
            I18n.translate!(
                'metasploit.model.errors.models.metasploit_data_models/search/operation/ip_address/v4/range.attributes.value.extreme',
                extreme: :begin,
                extreme_value: range_begin
            )
          }

          context 'with IPAddr' do
            context 'with IPv4' do
              context 'with CIDR' do
                let(:range_begin) {
                  IPAddr.new('1.2.3.4/31')
                }

                it { should include(error) }
              end

              context 'with single' do
                it { should_not include(error) }
              end
            end
          end
        end

        context 'Range#end' do
          let(:error) {
            I18n.translate!(
                'metasploit.model.errors.models.metasploit_data_models/search/operation/ip_address/v4/range.attributes.value.extreme',
                extreme: :end,
                extreme_value: range_end
            )
          }

          context 'with IPAddr' do
            context 'with IPv4' do
              context 'with CIDR' do
                let(:range_end) {
                  IPAddr.new('5.6.7.8/30')
                }

                it { should include(error) }
              end

              context 'with single' do
                it { should_not include(error) }
              end
            end
          end
        end

        context 'order' do
          let(:error) {
            I18n.translate!(
                'metasploit.model.errors.models.metasploit_data_models/search/operation/ip_address/v4/range.attributes.value.order',
                begin: range_begin,
                end: range_end
            )
          }

          context 'with begin before or same as end' do
            it { should_not include error }
          end

          context 'with begin after end' do
            let(:range_begin) {
              IPAddr.new('8.7.6.5')
            }

            let(:range_end) {
              IPAddr.new('4.3.2.1')
            }

            it { should include error }
          end
        end
      end

      context 'without Range' do
        let(:error) {
          I18n.translate!('metasploit.model.errors.models.metasploit_data_models/search/operation/ip_address/v4/range.attributes.value.type')
        }

        let(:formatted_value) {
          '1.2.3.4'
        }

        it { should include(error) }
      end
    end
  end

  it_should_behave_like 'MetasploitDataModels::Search::Operation::IPAddress::*.match',
                        4 => :range
end