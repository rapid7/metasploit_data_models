require 'spec_helper'

describe MetasploitDataModels::Search::Visitor::Includes do
  subject(:visitor) do
    described_class.new
  end

  it_should_behave_like 'Metasploit::Concern.run'

  context '#visit' do
    subject(:visit) do
      visitor.visit(node)
    end

    children_classes = [
        Metasploit::Model::Search::Group::Intersection,
        Metasploit::Model::Search::Group::Union,
        Metasploit::Model::Search::Operation::Union
    ]

    children_classes.each do |children_class|
      context "with #{children_class}" do
        it_should_behave_like "MetasploitDataModels::Search::Visitor::Includes#visit with #children" do
          let(:node_class) do
            children_class
          end
        end
      end
    end

    operation_classes = [
        Metasploit::Model::Search::Operation::Boolean,
        Metasploit::Model::Search::Operation::Date,
        Metasploit::Model::Search::Operation::Integer,
        Metasploit::Model::Search::Operation::Null,
        Metasploit::Model::Search::Operation::Set::Integer,
        Metasploit::Model::Search::Operation::Set::String,
        Metasploit::Model::Search::Operation::String
    ]

    operation_classes.each do |operation_class|
      context "with #{operation_class}" do
        it_should_behave_like 'MetasploitDataModels::Search::Visitor::Includes#visit with Metasploit::Model::Search::Operation::Base' do
          let(:node_class) do
            operation_class
          end
        end
      end
    end

    context 'with Metasploit::Model::Search::Operation::Union' do
      let(:node) do

      end
    end

    context 'with Metasploit::Model::Search::Operator::Association' do
      let(:association) do
        FactoryGirl.generate :metasploit_model_search_operator_association_association
      end

      let(:node) do
        Metasploit::Model::Search::Operator::Association.new(
            :association => association
        )
      end

      it 'should include association' do
        visit.should include(association)
      end
    end

    context 'with Metasploit::Model::Search::Operator::Attribute' do
      let(:node) do
        Metasploit::Model::Search::Operator::Attribute.new
      end

      it { should == [] }
    end

    context 'with Metasploit::Model::Search::Query#tree' do
      let(:node) do
        query.tree
      end

      let(:query) do
        Metasploit::Model::Search::Query.new(
            :formatted => formatted,
            :klass => klass
        )
      end

      context 'Metasploit::Model::Search::Query#klass' do
        context 'with Mdm::Host' do
          let(:klass) {
            Mdm::Host
          }

          context 'with name' do
            let(:name) do
              FactoryGirl.generate :mdm_host_name
            end

            let(:formatted) do
              "name:\"#{name}\""
            end

            it { should be_empty }
          end

          context 'with services.name' do
            let(:name) do
              FactoryGirl.generate :mdm_service_name
            end

            let(:formatted) do
              "services.name:\"#{name}\""
            end

            it { should include :services }
          end
        end
      end
    end
  end
end