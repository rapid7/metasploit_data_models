require 'spec_helper'

describe MetasploitDataModels::Search::Operation::IPAddress::InvalidRange do
  subject(:operation) {
    described_class.new(
        operator: operator,
        value: formatted_value
    )
  }

  let(:formatted_value) {
    'a.b.c.d'
  }

  let(:operator) {
    double('MetasploitDataModels::Search::Operator::IPAddress::Range')
  }

  context 'validations' do
    context 'errors on #value' do
      subject(:value_errors) {
        operation.errors[:value]
      }

      #
      # lets
      #

      let(:error) {
        I18n.translate!('metasploit.model.errors.models.metasploit_data_models/search/operation/ip_address/invalid_range.attributes.value.format')
      }

      #
      # Callbacks
      #

      before(:each) do
        allow(operator).to receive(:valid?).and_return(true)

        operation.valid?
      end

      it { should include(error) }
    end
  end

  context 'match' do
    subject(:match) {
      described_class.match(formatted_value)
    }

    it { should be_a described_class }

    it 'does not set #operator' do
      expect(match.operator).to be_nil
    end

    it 'sets #value to given formatted_value' do
      expect(match.value).to eq(formatted_value)
    end
  end
end