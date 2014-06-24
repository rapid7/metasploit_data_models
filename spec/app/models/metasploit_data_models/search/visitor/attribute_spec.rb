require 'spec_helper'

describe MetasploitDataModels::Search::Visitor::Attribute do
  subject(:visitor) do
    described_class.new
  end

  context '#visit' do
    subject(:visit) do
      visitor.visit(node)
    end

    #
    # Shared examples
    #

    shared_examples_for 'operator.klass.arel_table[operator.attribute]' do |options = {}|
      options.assert_valid_keys(:node_class)

      node_class = options.fetch(:node_class)

      context "with #{node_class}" do
        it { should be_a Arel::Attributes::Attribute }

        context '#name' do
          subject(:name) do
            visit.name
          end

          it "should be #{node_class}#attribute" do
            name.should == node.attribute
          end
        end

        context '#relation' do
          subject(:relation) do
            visit.relation
          end

          it "should be Class#arel_table for #{node_class}#klass" do
            relation.should == node.klass.arel_table
          end
        end
      end
    end

    context 'with Metasploit::Model::Search::Operator::Association' do
      let(:attribute_operator) do
        double('Attribute Operator')
      end

      let(:node) do
        Metasploit::Model::Search::Operator::Association.new(
            :attribute_operator => attribute_operator
        )
      end

      it 'should visit Metasploit::Model::Search::Operator::Association#attribute_operator' do
        visitor.should_receive(:visit).with(node).and_call_original
        visitor.should_receive(:visit).with(attribute_operator)

        visit
      end

      it 'should return visit of Metasploit::Model::Search::Operator::Association#attribute_operator' do
        visitor.should_receive(:visit).with(node).and_call_original

        visited = double('Attribute Operator Visited')
        visitor.stub(:visit).with(attribute_operator).and_return(visited)

        visit.should == visited
      end
    end

    it_should_behave_like 'operator.klass.arel_table[operator.attribute]',
                          node_class: Metasploit::Model::Search::Operator::Attribute do
      let(:node) {
        Metasploit::Model::Search::Operator::Attribute.new(
            # needs to be a real column so look up on AREL table works
            attribute: :name,
            # needs to be a real class so Class#arel_table works
            klass: Mdm::Host
        )
      }
    end

    it_should_behave_like 'operator.klass.arel_table[operator.attribute]',
                          node_class: MetasploitDataModels::Search::Operator::Port::List do
      let(:node) {
        Metasploit::Model::Search::Operator::Attribute.new(
            klass: Mdm::Service
        )
      }
    end
  end
end