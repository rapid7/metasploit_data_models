require 'spec_helper'

describe MetasploitDataModels::Search::Operator::Multitext do
  subject(:multitext_operator) {
    described_class.new(
        attributes
    )
  }

  let(:attributes) {
    {}
  }

  context 'validations' do
    it { should ensure_length_of(:operator_names).is_at_least(2) }
    it { should validate_presence_of :name }
  end

  context '#children' do
    subject(:children) {
      multitext_operator.children(formatted_value)
    }

    let(:attributes) {
      {
          klass: klass,
          operator_names: operator_names
      }
    }

    let(:klass) {
      Mdm::Host
    }

    let(:operator_names) {
      [
          :os_flavor,
          :os_name,
          :os_sp
      ]
    }

    context 'with nil' do
      let(:formatted_value) {
        nil
      }

      it { should == [] }
    end

    context 'with empty String' do
      let(:formatted_value) {
        ''
      }

      it { should == [] }
    end

    context 'without quotes' do
      let(:formatted_value) {
        words.join(' ')
      }

      let(:words) {
        %w{multiple words}
      }

      it 'generates operation for each word and operator combination' do
        operations_by_operator = children.group_by(&:operator)

        operator_names.each do |operator_name|
          operator = klass.search_operator_by_name[operator_name]

          expect(operator).not_to be_nil

          operations = operations_by_operator[operator]

          expect(operations).not_to be_nil
          expect(operations.map(&:value)).to match_array(words)
        end
      end
    end

    context 'with quotes' do
      let(:formatted_value) {
        %Q{"quoted words"}
      }

      it 'generates operation for quoted words as a single argument' do
        value_set = children.each_with_object(Set.new) { |operation, set|
          set.add operation.value
        }

        expect(value_set).to eq(Set.new(['quoted words']))
      end
    end
  end

  context '#name' do
    subject(:name) {
      multitext_operator.name
    }

    context 'default' do
      it { should be_nil }
    end

    context 'setter' do
      let(:new_name) {
        :new_name
      }

      it 'sets #name' do
        expect {
          multitext_operator.name = new_name
        }.to change(multitext_operator, :name).to(new_name)
      end
    end
  end

  context '#operator_names' do
    subject(:operator_names) {
      multitext_operator.operator_names
    }

    context 'default' do
      it { should == [] }
    end
  end

  context '#operators' do
    subject(:operators) {
      multitext_operator.operators
    }

    let(:attributes) {
      {
          klass: klass,
          operator_names: operator_names
      }
    }

    let(:klass) {
      Mdm::Host
    }

    let(:operator_names) {
      [
          :os_flavor,
          :os_name,
          :os_sp
      ]
    }

    it 'looks up all operators by name using #operator' do
      operator_names.each do |operator_name|
        expect(multitext_operator).to receive(:operator).with(operator_name).and_call_original
      end

      operators
    end
  end
end