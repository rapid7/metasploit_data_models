RSpec.describe MetasploitDataModels::IPAddress::V4::CIDR, type: :model do
  subject(:cidr) {
    described_class.new(
        value: formatted_value
    )
  }

  let(:formatted_value) {
    nil
  }

  it { should be_a MetasploitDataModels::IPAddress::CIDR }

  context 'address_class' do
    subject(:address_class) {
      described_class.address_class
    }

    it { should == MetasploitDataModels::IPAddress::V4::Single }
  end

  context 'validations' do
    let(:formatted_address) {
      '1.2.3.4'
    }

    context 'with IPv4 CIDR notation' do
      let(:formatted_prefix_length) {
        '8'
      }

      let(:formatted_value) {
        "#{formatted_address}/#{formatted_prefix_length}"
      }

      it { should be_valid }
    end

    context 'with IPv4 address' do
      let(:formatted_value) {
        formatted_address
      }

      it { should_not be_valid }

      context 'errors' do
        before(:each) do
          cidr.valid?
        end

        context 'on #address' do
          subject(:address_errors) {
            cidr.errors[:address]
          }

          it { should be_empty }
        end

        context 'on #prefix_length' do
          subject(:prefix_length_errors) {
            cidr.errors[:prefix_length]
          }

          let(:blank_error) {
            I18n.translate!('errors.messages.not_a_number')
          }

          it { should include(blank_error) }
        end
      end
    end

    context 'with IPv6 CIDR notation' do
      let(:formatted_value) {
        "#{formatted_address}/#{formatted_prefix_length}"
      }

      let(:formatted_address) {
        '::1'
      }

      let(:formatted_prefix_length) {
        '48'
      }

      it { should_not be_valid }

      context 'errors' do
        before(:each) do
          cidr.valid?
        end

        context 'on #address' do
          subject(:address_errors) {
            cidr.errors[:address]
          }

          let(:invalid_error) {
            I18n.translate!('errors.messages.invalid')
          }

          it { should include(invalid_error) }
        end

        context 'on #prefix_length' do
          subject(:prefix_length_errors) {
            cidr.errors[:prefix_length]
          }

          let(:too_big_error) {
            I18n.translate!('errors.messages.less_than_or_equal_to', count: 32)
          }

          it { should include(too_big_error) }
        end
      end
    end
  end
end