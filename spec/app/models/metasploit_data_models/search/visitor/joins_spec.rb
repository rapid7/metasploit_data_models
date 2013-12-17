require 'spec_helper'

describe MetasploitDataModels::Search::Visitor::Joins do
  subject(:visitor) do
    described_class.new
  end

  context '#visit' do
    subject(:visit) do
      visitor.visit(node)
    end

    context 'with Metasploit::Model::Search::Group::Intersection' do
      let(:children) do
        2.times.collect { |n|
          double("Child #{n}")
        }
      end

      let(:node) do
        Metasploit::Model::Search::Group::Intersection.new(
            :children => children
        )
      end

      it 'should visit each child' do
        # needed for call to visit subject
        visitor.should_receive(:visit).with(node).and_call_original

        children.each do |child|
          visitor.should_receive(:visit).with(child).and_return([])
        end

        visit
      end

      it 'should return Array of all child visits' do
        child_visits = []

        visitor.should_receive(:visit).with(node).and_call_original

        children.each_with_index do |child, i|
          child_visit = ["Visited Child #{i}"]
          visitor.stub(:visit).with(child).and_return(child_visit)
          child_visits.concat(child_visit)
        end

        visit.should == child_visits
      end
    end

    union_classes = [
        Metasploit::Model::Search::Group::Union,
        Metasploit::Model::Search::Operation::Union
    ]

    union_classes.each do |union_class|
      context "with #{union_class}" do
        let(:node) do
          union_class.new(
              children: children
          )
        end

        context 'with children' do
          context 'without child joins' do
            let(:children) do
              Array.new(2) {
                Metasploit::Model::Search::Operator::Attribute.new
              }
            end

            it { should == [] }
          end

          context 'with association and attribute' do
            let(:association) do
              FactoryGirl.generate :metasploit_model_search_operator_association_association
            end

            let(:association_operator) do
              Metasploit::Model::Search::Operator::Association.new(
                  association: association
              )
            end

            let(:attribute_operator) do
              Metasploit::Model::Search::Operator::Attribute.new
            end

            let(:children) do
              [
                  association_operator,
                  attribute_operator
              ]
            end

            it { should == [] }
          end

          context 'with the same child join for all' do
            let(:association) do
              FactoryGirl.generate :metasploit_model_search_operator_association_association
            end

            let(:association_operator) do
              Metasploit::Model::Search::Operator::Association.new(
                  association: association
              )
            end

            let(:children) do
              Array.new(2) {
                association_operator
              }
            end

            it 'should include association' do
              visit.should include association
            end
          end

          context 'with union of intersections' do
            let(:disjoint_associations) do
              Array.new(2) {
                FactoryGirl.generate :metasploit_model_search_operator_association_association
              }
            end

            let(:first_associations) do
              disjoint_associations[0, 1] + common_associations
            end

            let(:first_association_operators) do
              first_associations.collect { |association|
                Metasploit::Model::Search::Operator::Association.new(
                    association: association
                )
              }
            end

            let(:second_associations) do
              disjoint_associations[1, 1] + common_associations
            end

            let(:second_association_operators) do
              second_associations.collect { |association|
                Metasploit::Model::Search::Operator::Association.new(
                    association: association
                )
              }
            end

            let(:children) do
              [first_association_operators, second_association_operators].collect { |grandchildren|
                Metasploit::Model::Search::Group::Intersection.new(
                    children: grandchildren
                )
              }
            end

            context 'with a common subset of child join' do
              let(:common_associations) do
                Array.new(2) {
                  FactoryGirl.generate :metasploit_model_search_operator_association_association
                }
              end

              it 'should include common associations' do
                common_associations.each do |association|
                  visit.should include(association)
                end
              end

              it 'should not include disjoint associations' do
                disjoint_associations.each do |association|
                  visit.should_not include(association)
                end
              end
            end

            context 'without a common subset of child joins' do
              let(:common_associations) do
                []
              end

              it { should == [] }
            end
          end
        end

        context 'without children' do
          let(:children) do
            []
          end

          it { should == [] }
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

    context "with Metasploit::Model::Search::Operator::Attribute" do
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
            :klass => Mdm::Module::Instance
        )
      end

      context 'with description' do
        let(:description) do
          FactoryGirl.generate :metasploit_model_module_instance_description
        end

        let(:formatted) do
          "description:\"#{description}\""
        end

        it { should be_empty }
      end

      context 'with disclosed_on' do
        let(:disclosed_on) do
          FactoryGirl.generate :metasploit_model_module_instance_disclosed_on
        end

        let(:formatted) do
          "disclosed_on:\"#{disclosed_on}\""
        end

        it { should be_empty }
      end

      context 'with license' do
        let(:license) do
          FactoryGirl.generate :metasploit_model_module_instance_license
        end

        let(:formatted) do
          "license:\"#{license}\""
        end

        it { should be_empty }
      end

      context 'with name' do
        let(:name) do
          FactoryGirl.generate :metasploit_model_module_instance_name
        end

        let(:formatted) do
          "name:\"#{name}\""
        end

        it { should be_empty }
      end

      context 'with privileged' do
        let(:privileged) do
          FactoryGirl.generate :metasploit_model_module_instance_privileged
        end

        let(:formatted) do
          "privileged:#{privileged}"
        end

        it { should be_empty }
      end

      context 'with stance' do
        let(:stance) do
          FactoryGirl.generate :metasploit_model_module_stance
        end

        let(:formatted) do
          "stance:#{stance}"
        end

        it { should be_empty }
      end

      context 'with actions.name' do
        let(:name) do
          FactoryGirl.generate :metasploit_model_module_action_name
        end

        let(:formatted) do
          "actions.name:\"#{name}\""
        end

        it { should include :actions }
      end

      context 'with architectures.abbreviation' do
        let(:abbreviation) do
          FactoryGirl.generate :metasploit_model_architecture_abbreviation
        end

        let(:formatted) do
          "architectures.abbreviation:#{abbreviation}"
        end

        it { should include :architectures }
      end

      context 'with architectures.bits' do
        let(:bits) do
          FactoryGirl.generate :metasploit_model_architecture_bits
        end

        let(:formatted) do
          "architectures.bits:#{bits}"
        end

        it { should include :architectures }
      end

      context 'with architectures.endianness' do
        let(:endianness) do
          FactoryGirl.generate :metasploit_model_architecture_endianness
        end

        let(:formatted) do
          "architectures.endianness:#{endianness}"
        end

        it { should include :architectures }
      end

      context 'with architectures.family' do
        let(:family) do
          FactoryGirl.generate :metasploit_model_architecture_family
        end

        let(:formatted) do
          "architectures.family:#{family}"
        end

        it { should include :architectures }
      end

      context 'with authorities.abbreviation' do
        let(:abbreviation) do
          FactoryGirl.generate :metasploit_model_authority_abbreviation
        end

        let(:formatted) do
          "authorities.abbreviation:#{abbreviation}"
        end

        it { should include :authorities }
      end

      context 'with authors.name' do
        let(:name) do
          FactoryGirl.generate :metasploit_model_author_name
        end

        let(:formatted) do
          "authors.name:\"#{name}\""
        end

        it { should include :authors }
      end

      context 'with email_addresses.domain' do
        let(:domain) do
          FactoryGirl.generate :metasploit_model_email_address_domain
        end

        let(:formatted) do
          "email_addresses.domain:#{domain}"
        end

        it { should include :email_addresses }
      end

      context 'with email_addresses.local' do
        let(:local) do
          FactoryGirl.generate :metasploit_model_email_address_local
        end

        let(:formatted) do
          "email_addresses.local:#{local}"
        end

        it { should include :email_addresses }
      end

      context 'with module_class.full_name' do
        let(:full_name) do
          "#{module_type}/#{reference_name}"
        end

        let(:formatted) do
          "module_class.full_name:#{full_name}"
        end

        let(:module_type) do
          FactoryGirl.generate :metasploit_model_non_payload_module_type
        end

        let(:reference_name) do
          FactoryGirl.generate :metasploit_model_module_ancestor_non_payload_reference_name
        end

        it { should include :module_class }
      end

      context 'with module_class.module_type' do
        let(:formatted) do
          "module_class.module_type:#{module_type}"
        end

        let(:module_type) do
          FactoryGirl.generate :metasploit_model_module_type
        end

        it { should include :module_class }
      end

      context 'with module_class.payload_type' do
        let(:formatted) do
          "module_class.payload_type:#{payload_type}"
        end

        let(:payload_type) do
          FactoryGirl.generate :metasploit_model_module_class_payload_type
        end

        it { should include :module_class }
      end

      context 'with module_class.reference_name' do
        let(:formatted) do
          "module_class.reference_name:#{reference_name}"
        end

        let(:reference_name) do
          FactoryGirl.generate :metasploit_model_module_ancestor_reference_name
        end

        it { should include :module_class }
      end

      context 'with platforms.fully_qualified_name' do
        let(:formatted) do
          "platforms.fully_qualified_name:\"#{fully_qualified_name}\""
        end

        let(:fully_qualified_name) do
          Metasploit::Model::Platform.fully_qualified_name_set.to_a.sample
        end

        it { should include :platforms }
      end

      context 'with rank.name' do
        let(:formatted) do
          "rank.name:#{name}"
        end

        let(:name) do
          FactoryGirl.generate :metasploit_model_module_rank_name
        end

        it { should include :rank }
      end

      context 'with rank.number' do
        let(:formatted) do
          "rank.number:#{number}"
        end

        let(:number) do
          FactoryGirl.generate :metasploit_model_module_rank_number
        end

        it { should include :rank }
      end

      context 'with references.designation' do
        let(:designation) do
          FactoryGirl.generate :metasploit_model_reference_designation
        end

        let(:formatted) do
          "references.designation:#{designation}"
        end

        it { should include :references }
      end

      context 'with references.url' do
        let(:formatted) do
          "references.url:#{url}"
        end

        let(:url) do
          FactoryGirl.generate :metasploit_model_reference_url
        end

        it { should include :references }
      end

      context 'with targets.name' do
        let(:formatted) do
          "targets.name:\"#{name}\""
        end

        let(:name) do
          FactoryGirl.generate :metasploit_model_module_target_name
        end

        it { should include :targets }
      end
    end
  end
end