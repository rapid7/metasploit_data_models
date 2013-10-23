require 'spec_helper'

describe MetasploitDataModels::Search::Visitor::Where do
  subject(:visitor) do
    described_class.new
  end

  context '#attribute_visitor' do
    subject(:attribute_visitor) do
      visitor.attribute_visitor
    end

    it { should be_a MetasploitDataModels::Search::Visitor::Attribute }
  end

  context '#method_visitor' do
    subject(:method_visitor) do
      visitor.method_visitor
    end

    it { should be_a MetasploitDataModels::Search::Visitor::Method }
  end

  context '#visit' do
    subject(:visit) do
      visitor.visit(node)
    end

    arel_class_by_group_class = {
        Metasploit::Model::Search::Group::Intersection => Arel::Nodes::And,
        Metasploit::Model::Search::Group::Union => Arel::Nodes::Or
    }

    arel_class_by_group_class.each do |group_class, arel_class|
      context "with #{group_class}" do
        it_should_behave_like 'MetasploitDataModels::Search::Visitor::Where#visit with Metasploit::Model::Search::Group::Base',
                              :arel_class => arel_class do
          let(:node_class) do
            group_class
          end
        end
      end
    end

    equality_operation_classes = [
        Metasploit::Model::Search::Operation::Boolean,
        Metasploit::Model::Search::Operation::Date,
        Metasploit::Model::Search::Operation::Integer,
        Metasploit::Model::Search::Operation::Set::Integer,
        Metasploit::Model::Search::Operation::Set::String
    ]

    equality_operation_classes.each do |operation_class|
      context "with #{operation_class}" do
        it_should_behave_like 'MetasploitDataModels::Search::Visitor::Where#visit with equality operation' do
          let(:node_class) do
            operation_class
          end
        end
      end
    end

    context 'with Metasploit::Model::Search::Operation::String' do
      let(:node) do
        Metasploit::Model::Search::Operation::String.new(
            :operator => operator,
            :value => value
        )
      end

      let(:operator) do
        Metasploit::Model::Search::Operator::Attribute.new(
            :klass => Mdm::Module::Class,
            :attribute => :module_type
        )
      end

      let(:value) do
        'aux'
      end

      it 'should visit operation.operator with attribute_visitor' do
        visitor.attribute_visitor.should_receive(:visit).with(operator).and_call_original

        visit
      end

      it 'should call matches on Arel::Attributes::Attribute from attribute_visitor' do
        attribute = double('Visited Operator')
        visitor.attribute_visitor.stub(:visit).with(operator).and_return(attribute)

        attribute.should_receive(:matches).with("%#{value}%")

        visit
      end
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

        it 'should match module_instances.description with ILIKE' do
          visit.to_sql.should == "\"module_instances\".\"description\" ILIKE '%#{description}%'"
        end
      end

      context 'with disclosed_on' do
        let(:disclosed_on) do
          FactoryGirl.generate :metasploit_model_module_instance_disclosed_on
        end

        let(:formatted) do
          "disclosed_on:\"#{disclosed_on}\""
        end

        it 'should match module_instances.disclosed_on with =' do
          visit.to_sql.should == "\"module_instances\".\"disclosed_on\" = '#{disclosed_on}'"
        end
      end

      context 'with license' do
        let(:license) do
          FactoryGirl.generate :metasploit_model_module_instance_license
        end

        let(:formatted) do
          "license:\"#{license}\""
        end

        it 'should match module_instances.license with ILIKE' do
          visit.to_sql.should == "\"module_instances\".\"license\" ILIKE '%#{license}%'"
        end
      end

      context 'with name' do
        let(:name) do
          FactoryGirl.generate :metasploit_model_module_instance_name
        end

        let(:formatted) do
          "name:\"#{name}\""
        end

        it 'should match module_instances.name with ILIKE' do
          visit.to_sql.should == "\"module_instances\".\"name\" ILIKE '%#{name}%'"
        end
      end

      context 'with privileged' do
        def format_boolean(boolean)
          {
              false => 'f',
              true => 't'
          }.fetch(boolean)
        end

        let(:privileged) do
          FactoryGirl.generate :metasploit_model_module_instance_privileged
        end

        let(:formatted) do
          "privileged:#{privileged}"
        end

        it 'should match module_instances.privileged with =' do
          visit.to_sql.should == "\"module_instances\".\"privileged\" = '#{format_boolean(privileged)}'"
        end
      end

      context 'with stance' do
        let(:stance) do
          FactoryGirl.generate :metasploit_model_module_stance
        end

        let(:formatted) do
          "stance:#{stance}"
        end

        it 'should match module_instances.stance with ILIKE' do
          visit.to_sql.should == "\"module_instances\".\"stance\" ILIKE '%#{stance}%'"
        end
      end

      context 'with actions.name' do
        let(:name) do
          FactoryGirl.generate :metasploit_model_module_action_name
        end

        let(:formatted) do
          "actions.name:\"#{name}\""
        end

        it 'should match module_actions.name with ILIKE' do
          visit.to_sql.should == "\"module_actions\".\"name\" ILIKE '%#{name}%'"
        end
      end

      context 'with architectures.abbreviation' do
        let(:abbreviation) do
          FactoryGirl.generate :metasploit_model_architecture_abbreviation
        end

        let(:formatted) do
          "architectures.abbreviation:#{abbreviation}"
        end

        it 'should match architectures.abbreviation with =' do
          visit.to_sql.should == "\"architectures\".\"abbreviation\" = '#{abbreviation}'"
        end
      end

      context 'with architectures.bits' do
        let(:bits) do
          FactoryGirl.generate :metasploit_model_architecture_bits
        end

        let(:formatted) do
          "architectures.bits:#{bits}"
        end

        it 'should match architectures.bits with =' do
          visit.to_sql.should == "\"architectures\".\"bits\" = #{bits}"
        end
      end

      context 'with architectures.endianness' do
        let(:endianness) do
          FactoryGirl.generate :metasploit_model_architecture_endianness
        end

        let(:formatted) do
          "architectures.endianness:#{endianness}"
        end

        it 'should match architectures.endianness with =' do
          visit.to_sql.should == "\"architectures\".\"endianness\" = '#{endianness}'"
        end
      end

      context 'with architectures.family' do
        let(:family) do
          FactoryGirl.generate :metasploit_model_architecture_family
        end

        let(:formatted) do
          "architectures.family:#{family}"
        end

        it 'should match architectures.family with =' do
          visit.to_sql.should == "\"architectures\".\"family\" = '#{family}'"
        end
      end

      context 'with authorities.abbreviation' do
        let(:abbreviation) do
          FactoryGirl.generate :metasploit_model_authority_abbreviation
        end

        let(:formatted) do
          "authorities.abbreviation:#{abbreviation}"
        end

        it 'should match authorities.abbreviation with ILIKE' do
          visit.to_sql.should == "\"authorities\".\"abbreviation\" ILIKE '%#{abbreviation}%'"
        end
      end

      context 'with authors.name' do
        let(:name) do
          FactoryGirl.generate :metasploit_model_author_name
        end

        let(:formatted) do
          "authors.name:\"#{name}\""
        end

        it 'should match authors.name with ILIKE' do
          visit.to_sql.should == "\"authors\".\"name\" ILIKE '%#{name}%'"
        end
      end

      context 'with email_addresses.domain' do
        let(:domain) do
          FactoryGirl.generate :metasploit_model_email_address_domain
        end

        let(:formatted) do
          "email_addresses.domain:#{domain}"
        end

        it 'should match email_addresses.domain with ILIKE' do
          visit.to_sql.should == "\"email_addresses\".\"domain\" ILIKE '%#{domain}%'"
        end
      end

      context 'with email_addresses.local' do
        let(:local) do
          FactoryGirl.generate :metasploit_model_email_address_local
        end

        let(:formatted) do
          "email_addresses.local:#{local}"
        end

        it 'should match email_addresses.local with ILIKE' do
          visit.to_sql.should == "\"email_addresses\".\"local\" ILIKE '%#{local}%'"
        end
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

        it 'should match module_classes.full_name with ILIKE' do
          visit.to_sql.should == "\"module_classes\".\"full_name\" ILIKE '%#{full_name}%'"
        end
      end

      context 'with module_class.module_type' do
        let(:formatted) do
          "module_class.module_type:#{module_type}"
        end

        let(:module_type) do
          FactoryGirl.generate :metasploit_model_module_type
        end

        it 'should match module_classes.module_type with ILIKE' do
          visit.to_sql.should == "\"module_classes\".\"module_type\" ILIKE '%#{module_type}%'"
        end
      end

      context 'with module_class.payload_type' do
        let(:formatted) do
          "module_class.payload_type:#{payload_type}"
        end

        let(:payload_type) do
          FactoryGirl.generate :metasploit_model_module_class_payload_type
        end

        it 'should match module_classes.payload_type with ILIKE' do
          visit.to_sql.should == "\"module_classes\".\"payload_type\" ILIKE '%#{payload_type}%'"
        end
      end

      context 'with module_class.reference_name' do
        let(:formatted) do
          "module_class.reference_name:#{reference_name}"
        end

        let(:reference_name) do
          FactoryGirl.generate :metasploit_model_module_ancestor_reference_name
        end

        it 'should match module_classes.reference_name with ILIKE' do
          visit.to_sql.should == "\"module_classes\".\"reference_name\" ILIKE '%#{reference_name}%'"
        end
      end

      context 'with platforms.fully_qualified_name' do
        let(:fully_qualified_name) do
          Metasploit::Model::Platform.fully_qualified_name_set.to_a.sample
        end

        let(:formatted) do
          "platforms.fully_qualified_name:\"#{fully_qualified_name}\""
        end

        it 'should match platforms.name with =' do
          visit.to_sql.should == "\"platforms\".\"fully_qualified_name\" = '#{fully_qualified_name}'"
        end
      end

      context 'with rank.name' do
        let(:formatted) do
          "rank.name:#{name}"
        end

        let(:name) do
          FactoryGirl.generate :metasploit_model_module_rank_name
        end

        it 'should match module_ranks.name with ILIKE' do
          visit.to_sql.should == "\"module_ranks\".\"name\" ILIKE '%#{name}%'"
        end
      end

      context 'with rank.number' do
        let(:formatted) do
          "rank.number:#{number}"
        end

        let(:number) do
          FactoryGirl.generate :metasploit_model_module_rank_number
        end

        it 'should match module_ranks.number with =' do
          visit.to_sql.should == "\"module_ranks\".\"number\" = #{number}"
        end
      end

      context 'with references.designation' do
        let(:designation) do
          FactoryGirl.generate :metasploit_model_reference_designation
        end

        let(:formatted) do
          "references.designation:#{designation}"
        end

        it 'should match references.designation with ILIKE' do
          visit.to_sql.should == "\"references\".\"designation\" ILIKE '%#{designation}%'"
        end
      end

      context 'with references.url' do
        let(:formatted) do
          "references.url:#{url}"
        end

        let(:url) do
          FactoryGirl.generate :metasploit_model_reference_url
        end

        it 'should match references.url with ILIKE' do
          visit.to_sql.should == "\"references\".\"url\" ILIKE '%#{url}%'"
        end
      end

      context 'with targets.name' do
        let(:formatted) do
          "targets.name:\"#{name}\""
        end

        let(:name) do
          FactoryGirl.generate :metasploit_model_module_target_name
        end

        it 'should match module_targets.name with ILIKE' do
          visit.to_sql.should == "\"module_targets\".\"name\" ILIKE '%#{name}%'"
        end
      end
    end
  end
end