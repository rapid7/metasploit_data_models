require 'spec_helper'

describe MetasploitDataModels::Search::Operation::IPAddress, type: :model do
  subject(:operation) {
    described_class.new(
        operator: operator,
        value: formatted_value
    )
  }

  let(:operator) {
    MetasploitDataModels::Search::Operator::IPAddress.new
  }

  context 'validation' do
    #
    # lets
    #

    let(:blank_error) {
      I18n.translate!('errors.messages.blank')
    }

    let(:invalid_error) {
      I18n.translate!('errors.messages.invalid')
    }

    #
    # Callbacks
    #

    before(:each) do
      operation.valid?
    end

    context 'errors on #value' do
      subject(:value_error) do
        operation.errors[:value]
      end

      context 'with IPv4' do
        context 'with CIDR' do
          context 'with valid prefix_length' do
            let(:formatted_value) {
              '1.2.3.4/8'
            }

            it { should be_empty }
          end

          context 'without valid prefix_length' do
            let(:formatted_value) {
              '1.2.3.4/36'
            }

            it { should include invalid_error }
          end
        end

        context 'with Nmap', pending: 'MSP-10712' do
          context 'with valid segment range' do
            let(:formatted_value) {
              '1-2.3.4.5'
            }

            it { should be_empty }
          end

          context 'without valid segment range' do
            let(:formatted_value) {
              '2-1.3.4.5'
            }

            it { should include invalid_error }
          end
        end

        context 'with Range' do
          context 'with ordered range' do
            let(:formatted_value) {
              '2.2.2.2-1.1.1.1'
            }

            it { should include invalid_error }
          end

          context 'without ordered range' do
            let(:formatted_value) {
              '1.1.1.1-2.2.2.2'
            }

            it { should be_empty }
          end
        end

        context 'with address' do
          let(:formatted_value) {
            '1.2.3.4'
          }

          it { be_empty }
        end
      end

      context 'with nil' do
        let(:formatted_value) {
          nil
        }

        it { should include blank_error }
        it { should_not include invalid_error }
      end

      context 'with empty string' do
        let(:formatted_value) {
          ''
        }

        it { should include blank_error }
        it { should_not include invalid_error }
      end

      context 'without matching formatted value' do
        let(:formatted_value) {
          'non_matching_value'
        }

        it { should include invalid_error }
      end
    end
  end

  context '#value' do
    subject(:value) {
      operation.value
    }

    context 'with IPv4' do
      context 'with CIDR' do
        let(:formatted_value) {
          '1.2.3.4/8'
        }

        it { should be_a MetasploitDataModels::IPAddress::V4::CIDR }
      end

      context 'with Nmap', pending: 'MSP-10712' do
        let(:formatted_value) {
          '1.2.3.4-5'
        }

        it { should be_a MetasploitDataModels::IPAddress::V4::Nmap }
      end

      context 'with Range' do
        let(:formatted_value) {
          '1.1.1.1-2.2.2.2'
        }

        it { should be_a MetasploitDataModels::IPAddress::V4::Range }
      end

      context 'with address' do
        let(:formatted_value) {
          '1.2.3.4'
        }

        it { should be_a MetasploitDataModels::IPAddress::V4::Single }
      end
    end

    context 'without support format' do
      let(:formatted_value) {
        'unsupported_formated'
      }

      it 'is the passed formatted value' do
        expect(value).to eq(formatted_value)
      end
    end
  end
end