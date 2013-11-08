require 'spec_helper'

describe MetasploitDataModels::Search::Visitor::Relation do
  subject(:visitor) do
    described_class.new(
        :query => query
    )
  end

  let(:formatted) do
    # needs to be a valid operation so that query is valid
    "name:\"A module\""
  end

  let(:query) do
    Metasploit::Model::Search::Query.new(
        :formatted => formatted,
        :klass => Mdm::Module::Instance
    )
  end

  context 'validations' do
    context 'query' do
      it { should validate_presence_of(:query) }

      context 'valid' do
        let(:error) do
          I18n.translate('errors.messages.invalid')
        end

        let(:errors) do
          visitor.errors[:query]
        end

        context 'with query' do
          let(:query) do
            double('Query')
          end

          before(:each) do
            query.stub(:valid? => query)

            visitor.valid?
          end

          context 'with valid' do
            let(:valid) do
              true
            end

            it 'should not record error' do
              errors.should_not include(error)
            end
          end

          context 'without valid' do
            let(:valid) do
              false
            end

            it 'should record error' do
              errors.should_not include(error)
            end
          end
        end

        context 'without query' do
          let(:query) do
            nil
          end

          it 'should not record error' do
            errors.should_not include(error)
          end
        end
      end
    end
  end

  context '#visit' do
    subject(:visit) do
      visitor.visit
    end

    context 'MetasploitDataModels::Search::Visitor::Includes' do
      subject(:includes_visitor) do
        visitor.visitor_by_relation_method[:includes]
      end

      it 'should visit Metasploit::Model::Search::Query#tree' do
        includes_visitor.should_receive(:visit).with(query.tree)

        visit
      end

      it 'should pass visited to ActiveRecord::Relation#includes' do
        visited = double('Visited')
        includes_visitor.stub(:visit).with(query.tree).and_return(visited)

        ActiveRecord::Relation.any_instance.should_receive(:includes).with(visited).and_return(query.klass.scoped)

        visit
      end
    end

    context 'MetasploitDataModels::Search::Visitor::Where' do
      subject(:where_visitor) do
        visitor.visitor_by_relation_method[:where]
      end

      it 'should visit Metasploit::Model::Search::Query#tree' do
        where_visitor.should_receive(:visit).with(query.tree)

        visit
      end

      it 'should pass visited to ActiveRecord::Relation#includes' do
        visited = double('Visited')
        where_visitor.stub(:visit).with(query.tree).and_return(visited)

        ActiveRecord::Relation.any_instance.should_receive(:where).with(visited).and_return(query.klass.scoped)

        visit
      end
    end

    context 'matching record' do
      #
      # let
      #

      let(:matching_module_class) do
        FactoryGirl.create(
            :mdm_module_class,
            module_type: module_type
        )
      end

      let(:matching_record) do
        FactoryGirl.build(
            :mdm_module_instance,
            module_class: matching_module_class
        )
      end

      let(:module_type) do
        module_types.sample
      end

      let(:module_types) do
        Metasploit::Model::Module::Type::ALL
      end

      let(:non_matching_module_class) do
        FactoryGirl.create(
            :mdm_module_class,
            module_type: module_type
        )
      end

      let(:non_matching_record) do
        FactoryGirl.build(
            :mdm_module_instance,
            module_class: non_matching_module_class
        )
      end

      #
      # Callbacks
      #

      before(:each) do
        # saved explicitly instead of with create so that lets can build and associations added on later.
        matching_record.save!
        non_matching_record.save!
      end

      it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                            :attribute => :description

      context 'with module type allows for attribute' do
        def attribute_module_types(attribute)
          Metasploit::Model::Module::Instance.module_types_that_allow(attribute)
        end

        #
        # lets
        #

        let(:module_types) do
          attribute_module_types(allows)
        end

        context 'with allows?(:actions)' do
          let(:allows) do
            :actions
          end

          it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                                :association => :actions,
                                :attribute => :name

          context 'with text' do
            let(:formatted) do
              "text:\"#{value}\""
            end

            context 'with Mdm::Module::Action#name' do
              let(:value) do
                matching_record.actions.sample.name
              end

              it 'should find only matching record' do
                expect(visit).to match_array([matching_record])
              end
            end
          end
        end

        context 'with allows?(:module_architectures)' do
          let(:allows) do
            :module_architectures
          end

          let(:module_types) do
            # exclude module types that support targets so target architectures don't need to be handled.
            super() - attribute_module_types(:targets)
          end

          let(:matching_record) do
            FactoryGirl.build(
                :mdm_module_instance,
                module_architectures_length: 0,
                module_class: matching_module_class
            ).tap { |module_instance|
              module_instance.module_architectures << FactoryGirl.build(
                  :mdm_module_architecture,
                  architecture: matching_architecture,
                  module_instance: module_instance
              )
            }
          end

          let(:non_matching_record) do
            FactoryGirl.build(
                :mdm_module_instance,
                module_architectures_length: 0,
                module_class: non_matching_module_class
            ).tap { |module_instance|
              module_instance.module_architectures << FactoryGirl.build(
                  :mdm_module_architecture,
                  architecture: non_matching_architecture,
                  module_instance: module_instance
              )
            }
          end

          it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                                :association => :architectures,
                                :attribute => :abbreviation do
            let(:matching_architecture) do
              Mdm::Architecture.where(:abbreviation => matching_abbreviation).first
            end

            let(:matching_abbreviation) do
              Metasploit::Model::Architecture::ABBREVIATIONS.sample
            end

            let(:non_matching_architecture) do
              Mdm::Architecture.where(:abbreviation => non_matching_abbreviation).first
            end

            let(:non_matching_abbreviation) do
              (Metasploit::Model::Architecture::ABBREVIATIONS - [matching_abbreviation]).sample
            end
          end

          it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                                :association => :architectures,
                                :attribute => :bits do
            # bits has only two values, so have to make sure that one 32 and one 64 bit architecture is chosen.
            let(:matching_architecture) do
              Mdm::Architecture.where(:bits => matching_bits).first
            end

            let(:matching_bits) do
              Metasploit::Model::Architecture::BITS.sample
            end

            let(:non_matching_architecture) do
              Mdm::Architecture.where(:bits => non_matching_bits).first
            end

            let(:non_matching_bits) do
              (Metasploit::Model::Architecture::BITS - [matching_bits]).sample
            end
          end

          it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                                :association => :architectures,
                                :attribute => :endianness do
            # endianness has only two values, so have to make sure that one big-endian and one little-endian architecture is
            # chosen.

            let(:matching_architecture) do
              Mdm::Architecture.where(:endianness => matching_endianness).first
            end

            let(:matching_endianness) do
              Metasploit::Model::Architecture::ENDIANNESSES.sample
            end

            let(:non_matching_architecture) do
              Mdm::Architecture.where(:endianness => non_matching_endianness).first
            end

            let(:non_matching_endianness) do
              (Metasploit::Model::Architecture::ENDIANNESSES - [matching_endianness]).sample
            end
          end

          it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                                :association => :architectures,
                                :attribute => :family do
            let(:matching_architecture) do
              Mdm::Architecture.where(:family => matching_family).first
            end

            let(:matching_family) do
              Metasploit::Model::Architecture::FAMILIES.sample
            end

            let(:non_matching_architecture) do
              Mdm::Architecture.where(:family => non_matching_family).first
            end

            let(:non_matching_family) do
              (Metasploit::Model::Architecture::FAMILIES - [matching_family]).sample
            end
          end

          context 'with text' do
            let(:formatted) do
              "text:\"#{value}\""
            end

            context 'with Mdm::Architecture#abbreviation' do
              let(:matching_architecture) do
                Mdm::Architecture.where(:abbreviation => matching_architecture_abbreviation).first
              end

              let(:matching_architecture_abbreviation) do
                # must not be a valid platform substring
                'armle'
              end

              let(:non_matching_architecture) do
                Mdm::Architecture.where(:abbreviation => non_matching_architecture_abbreviation).first
              end

              let(:non_matching_architecture_abbreviation) do
                # must not be a valid platform substring
                'armbe'
              end

              let(:value) do
                matching_architecture_abbreviation
              end

              it 'should find only matching record' do
                expect(visit).to match_array([matching_record])
              end
            end
          end
        end

        context 'with allows?(:module_platforms)' do
          #
          # Methods
          #

          def build_module_instance(module_class)
            FactoryGirl.build(
                :mdm_module_instance,
                module_class: module_class,
                module_platforms_length: 0,
                module_architectures_length: module_architectures_length,
                targets_length: 0
            )
          end

          #
          # lets
          #

          let(:allows) do
            :module_platforms
          end

          let(:matching_record) do
            build_module_instance(matching_module_class)
          end


          let(:non_matching_record) do
            build_module_instance(non_matching_module_class)
          end

          context 'with allows?(:targets)' do
            #
            # Methods
            #

            def build_module_instance(module_class)
              super(module_class).tap { |module_instance|
                FactoryGirl.build(
                    :mdm_module_target,
                    module_instance: module_instance,
                    # restrict to 1 architecture and 1 platform to prevent collisions
                    target_architectures_length: 1,
                    target_platforms_length: 1
                )
              }
            end

            #
            # lets
            #

            let(:module_architectures_length) do
              # module_architectures should be derived from targets target_architectures
              0
            end

            let(:module_platforms_module_types) do
              attribute_module_types(:module_platforms)
            end

            let(:module_types) do
              module_platforms_module_types & targets_module_types
            end

            let(:targets_module_types) do
              attribute_module_types(:targets)
            end

            it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record with Metasploit::Model::Search::Operator::Deprecated::Platform',
                                  :name => :os

            it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record with Metasploit::Model::Search::Operator::Deprecated::Platform',
                                  :name => :platform

            context 'with text' do
              let(:formatted) do
                "text:\"#{value}\""
              end

              context 'with Mdm::Platform#fully_qualified_name' do
                let(:value) do
                  matching_record.platforms.sample.fully_qualified_name
                end

                it 'should find only matching record' do
                  expect(visit).to match_array([matching_record])
                end
              end

              context 'with Mdm::Module::Target#name' do
                let(:value) do
                  matching_record.targets.sample.name
                end

                it 'should find only matching record' do
                  expect(visit).to match_array([matching_record])
                end
              end
            end
          end

          context 'without supports?(:targets)' do
            #
            # Methods
            #

            def build_module_instance(module_class)
              super(module_class).tap { |module_instance|
                module_instance.module_platforms << FactoryGirl.build(
                    :mdm_module_platform,
                    module_instance: module_instance
                )
              }
            end

            #
            # lets
            #

            let(:module_architectures_length) do
              # can allow module architectures directly on module instance since there are no targets to provide
              # target architectures to fill module architectures
              1
            end

            let(:module_types) do
              # disable module types with targets so that target platforms don't have to be considered
              super() - attribute_module_types(:targets)
            end


            it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                                  :association => :platforms,
                                  :attribute => :fully_qualified_name

          end
        end

        context 'with allows?(:module_references)' do
          let(:allows) do
            :module_references
          end

          let(:matching_record) do
            FactoryGirl.create(
                :mdm_module_instance,
                module_class: matching_module_class,
                module_references_length: 1
            )
          end

          let(:non_matching_record) do
            FactoryGirl.create(
                :mdm_module_instance,
                module_class: non_matching_module_class,
                module_references_length: 1
            )
          end

          it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                                :association => :authorities,
                                :attribute => :abbreviation

          it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                                :association => :references,
                                :attribute => :designation

          it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                                :association => :references,
                                :attribute => :url

          it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record with Metasploit::Model::Search::Operator::Deprecated::Authority',
                                :abbreviation => :bid

          it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record with Metasploit::Model::Search::Operator::Deprecated::Authority',
                                :abbreviation => :cve

          it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record with Metasploit::Model::Search::Operator::Deprecated::Authority',
                                :abbreviation => :edb

          it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record with Metasploit::Model::Search::Operator::Deprecated::Authority',
                                :abbreviation => :osvdb

          context 'with ref' do
            let(:formatted) do
              "ref:#{value}"
            end

            let(:matching_reference) do
              matching_record.references.sample
            end

            context 'with Mdm::Authority#abbreviation' do
              let(:value) do
                matching_reference.authority.abbreviation
              end

              it 'should find only matching record' do
                expect(visit).to match_array([matching_record])
              end
            end

            context 'with Mdm::Reference#designation' do
              #
              # lets
              #

              let(:matching_reference_designation) do
                'foo'
              end

              let(:non_matching_reference_designation) do
                'bar'
              end

              let(:reference_count) do
                # metasploit_model_reference_designation just generates numbers, but a lot of the other sequences contain
                # numbers, too, so using the factory generated designations can lead to substring matches on other fields
                # that ref searches, such as authors.name and references.url.
                0
              end

              let(:value) do
                matching_reference.designation
              end

              #
              # let!s
              #

              let!(:matching_module_reference) do
                FactoryGirl.create(
                    :mdm_module_reference,
                    :module_instance => matching_record,
                    :reference => matching_reference
                )
              end

              let!(:matching_reference) do
                FactoryGirl.create(
                    :mdm_reference,
                    :designation => matching_reference_designation
                )
              end

              let!(:non_matching_module_reference) do
                FactoryGirl.create(
                    :mdm_module_reference,
                    :module_instance => non_matching_record,
                    :reference => non_matching_reference
                )
              end

              let!(:non_matching_reference) do
                FactoryGirl.create(
                    :mdm_reference,
                    :designation => non_matching_reference_designation
                )
              end

              it 'should find only matching record' do
                expect(visit).to match_array([matching_record])
              end
            end

            context 'with Mdm::Reference#url' do
              let(:value) do
                matching_reference.url
              end

              it 'should find only matching record' do
                expect(visit).to match_array([matching_record])
              end
            end

            context "with 'URL-<Mdm::Reference#url>'" do
              let(:value) do
                "URL-#{matching_reference.url}"
              end

              it 'should find only matching record' do
                expect(visit).to match_array([matching_record])
              end
            end

            context "with '<Mdm::Authority#abbreviation>-<Mdm::Reference#designation>'" do
              let(:value) do
                "#{matching_reference.authority.abbreviation}-#{matching_reference.designation}"
              end

              it 'should find only matching record' do
                expect(visit).to match_array([matching_record])
              end
            end
          end

          context 'with text' do
            let(:formatted) do
              "text:\"#{value}\""
            end

            let(:matching_reference) do
              matching_record.references.sample
            end

            context 'with Mdm::Authority#abbreviation' do
              let(:value) do
                matching_reference.authority.abbreviation
              end

              it 'should find only matching record' do
                expect(visit).to match_array([matching_record])
              end
            end

            context 'with Mdm::Reference#designation' do
              #
              # lets
              #

              let(:matching_reference_designation) do
                'foo'
              end

              let(:non_matching_reference_designation) do
                'bar'
              end

              let(:reference_count) do
                # metasploit_model_reference_designation just generates numbers, but a lot of the other sequences contain
                # numbers, too, so using the factory generated designations can lead to substring matches on other fields
                # that ref searches, such as authors.name and references.url.
                0
              end

              let(:value) do
                matching_reference.designation
              end

              #
              # let!s
              #

              let!(:matching_module_reference) do
                FactoryGirl.create(
                    :mdm_module_reference,
                    :module_instance => matching_record,
                    :reference => matching_reference
                )
              end

              let!(:matching_reference) do
                FactoryGirl.create(
                    :mdm_reference,
                    :designation => matching_reference_designation
                )
              end

              let!(:non_matching_module_reference) do
                FactoryGirl.create(
                    :mdm_module_reference,
                    :module_instance => non_matching_record,
                    :reference => non_matching_reference
                )
              end

              let!(:non_matching_reference) do
                FactoryGirl.create(
                    :mdm_reference,
                    :designation => non_matching_reference_designation
                )
              end

              it 'should find only matching record' do
                expect(visit).to match_array([matching_record])
              end
            end

            context 'with Mdm::Reference#url' do
              let(:value) do
                matching_reference.url
              end

              it 'should find only matching record' do
                expect(visit).to match_array([matching_record])
              end
            end
          end
        end

        context 'with allow?(:targets)' do
          let(:allows) do
            :targets
          end

          it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                                :association => :targets,
                                :attribute => :name
        end
      end

      context 'with stanced' do
        let(:module_types) do
          Metasploit::Model::Module::Instance::STANCED_MODULE_TYPES
        end

        context 'with app' do
          let(:formatted) do
            "app:#{value}"
          end

          let(:value) do
            value_by_stance = {
                'aggressive' => 'server',
                'passive' => 'client'
            }

            value_by_stance.fetch(matching_record.stance)
          end

          it 'should find only matching record' do
            expect(visit).to match_array([matching_record])
          end
        end

        it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                              :attribute => :stance
      end

      it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                            :attribute => :disclosed_on

      it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                            :attribute => :license

      it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                            :attribute => :name

      it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                            :attribute => :privileged

      it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                            :association => :authors,
                            :attribute => :name

      context 'with email addresses' do
        let(:matching_record) do
          FactoryGirl.build(
              :mdm_module_instance,
              module_authors_length: 0
          ).tap { |module_instance|
            module_instance.module_authors << FactoryGirl.build(
                # full_mdm_module_author has an email_address
                :full_mdm_module_author,
                :module_instance => module_instance
            )
          }
        end

        let(:non_matching_record) do
          FactoryGirl.build(
              :mdm_module_instance,
              module_authors_length: 0
          ).tap { |module_instance|
            module_instance.module_authors << FactoryGirl.build(
                # full_mdm_module_author has an email_address
                :full_mdm_module_author,
                :module_instance => module_instance
            )
          }
        end

        before(:each) do
          matching_record.save!
          non_matching_record.save!
        end

        context 'with author' do
          let(:email_address) do
            matching_record.email_addresses.sample
          end

          let(:formatted) do
            # Mdm::Author#name may contain spaces.
            "author:\"#{value}\""
          end

          context 'with Mdm::Author#name' do
            let(:value) do
              matching_record.authors.sample.name
            end

            it 'should find only matching record' do
              expect(visit).to match_array([matching_record])
            end
          end

          context 'with EmailAddress#domain' do
            let(:value) do
              email_address.domain
            end

            it 'should find only matching record' do
              expect(visit).to match_array([matching_record])
            end
          end

          context 'with EmailAddress#local' do
            let(:value) do
              email_address.local
            end

            it 'should find only matching record' do
              expect(visit).to match_array([matching_record])
            end
          end
        end

        it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                              :association => :email_addresses,
                              :attribute => :domain

        it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                              :association => :email_addresses,
                              :attribute => :local
      end

      it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                            :association => :module_class,
                            :attribute => :full_name

      it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                            :association => :module_class,
                            :attribute => :module_type do
        let(:matching_module_type) do
          module_types.sample
        end

        let(:matching_module_class) do
          FactoryGirl.create(
              :mdm_module_class,
              module_type: matching_module_type
          )
        end

        let(:non_matching_module_type) do
          non_matching_module_types = module_types - [matching_module_type]

          non_matching_module_types.sample
        end

        let(:non_matching_module_class) do
          FactoryGirl.create(
              :mdm_module_class,
              module_type: non_matching_module_type
          )
        end
      end

      it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                            :association => :module_class,
                            :attribute => :payload_type do
        let(:matching_module_class) do
          FactoryGirl.create(
              :mdm_module_class,
              module_type: module_type
          )
        end

        let(:module_type) do
          Metasploit::Model::Module::Type::PAYLOAD
        end

        let(:non_matching_module_class) do
          FactoryGirl.create(
              :mdm_module_class,
              module_type: module_type
          )
        end
      end

      it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                            :association => :rank,
                            :attribute => :name

      it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                            :association => :rank,
                            :attribute => :number

      context 'with text' do
        #
        # lets
        #

        let(:formatted) do
          "text:\"#{value}\""
        end

        context 'with Mdm::Module::Instance#description' do
          let(:value) do
            matching_record.description
          end

          it 'should find only matching record' do
            expect(visit).to match_array([matching_record])
          end
        end

        context 'with Mdm::Module::Instance#name' do
          let(:value) do
            matching_record.name
          end

          it 'should find only matching record' do
            expect(visit).to match_array([matching_record])
          end
        end
      end

      context 'with all operators' do
        #
        # Local shared contexts
        #

        shared_context 'architectures' do
          include_context 'architectures attributes_by_association'

          let(:full_architectures) do
            architectures = Mdm::Architecture.arel_table

            full_query = architectures_attributes.inject(Mdm::Architecture) { |query, attribute|
              query.where(architectures[attribute].not_eq(nil))
            }

            # convert to array since it will be sampled
            full_query.to_a
          end

          let(:matching_architecture) do
            full_architectures.sample
          end

          let(:matching_record) do
            super().tap { |module_instance|
              module_instance.module_architectures << FactoryGirl.build(
                  :mdm_module_architecture,
                  architecture: matching_architecture,
                  module_instance: module_instance
              )
            }
          end

          let(:non_matching_architecture) do
            non_matching_architectures = full_architectures - [matching_architecture]

            non_matching_architectures.sample
          end

          let(:non_matching_record) do
            super().tap { |module_instance|
              module_instance.module_architectures << FactoryGirl.build(
                  :mdm_module_architecture,
                  architecture: non_matching_architecture,
                  module_instance: module_instance
              )
            }
          end
        end

        shared_context 'architectures attributes_by_association' do
          let(:architectures_attributes) do
            [
                :abbreviation,
                :bits,
                :endianness,
                :family
            ]
          end

          let(:attributes_by_association) do
            super().dup.tap { |attributes_by_association|
              attributes_by_association[:architectures] = architectures_attributes
            }
          end
        end

        shared_context 'platforms' do
          include_context 'platforms attributes_by_association'

          def build_module_instance(module_class)
            super(module_class).tap { |module_instance|
              module_instance.module_platforms << FactoryGirl.build(
                  :mdm_module_platform,
                  module_instance: module_instance
              )
            }
          end
        end

        shared_context 'platforms attributes_by_association' do
          let(:attributes_by_association) do
            super().merge(
                platforms: [
                    :fully_qualified_name
                ]
            )
          end
        end

        shared_context 'references' do
          let(:attributes_by_association) do
            super().merge(
                references: [
                    :designation,
                    :url
                ]
            )
          end
        end

        shared_context 'stance' do
          let(:attributes_by_association) do
            super().dup.tap { |attributes_by_association|
              # += so that original Array from super() is not modified
              attributes_by_association[nil] += [:stance]
            }
          end
        end

        shared_context 'targets' do
          include_context 'architectures attributes_by_association'
          include_context 'platforms attributes_by_association'

          def build_module_instance(module_class)
            super(module_class).tap { |module_instance|
              FactoryGirl.build(
                  :mdm_module_target,
                  module_instance: module_instance,
                  # restrict to single architecture and platform to prevent collisions
                  target_architectures_length: 1,
                  target_platforms_length: 1
              )
            }
          end
        end

        #
        # Methods
        #

        def build_module_instance(module_class)
          FactoryGirl.build(
              :mdm_module_instance,
              # (when supported) manually build module_architectures to ensure all fields are non-nil
              module_architectures_length: 0,
              # manually build module_authors to ensure they have email_addresses
              module_authors_length: 0,
              # manually build platforms so that normal platforms and target platforms don't interfere
              module_platforms_length: 0,
              module_class: module_class,
              # manually build targets to prevent target architecture and target platform collisions
              targets_length: 0
          ).tap { |module_instance|
            module_instance.module_authors << FactoryGirl.build(
                :full_mdm_module_author,
                module_instance: module_instance
            )
          }
        end

        #
        # lets
        #

        # operators common to all module types
        let(:attributes_by_association) do
          {
              nil => [
                  :description,
                  :disclosed_on,
                  :license,
                  :name,
                  :privileged
              ],
              :authors => [
                  :name
              ],
              :email_addresses => [
                  :domain,
                  :local
              ],
              :module_class => [
                  :full_name,
                  :module_type,
                  :reference_name
              ],
              :rank => [
                  :name,
                  :number
              ]
          }
        end

        let(:formatted) do
          formatted_operations.join(' ')
        end

        let(:formatted_operations) do
          attributes_by_association.flat_map { |association, attributes|
            attributes.collect { |attribute|
              if association
                formatted_operator = "#{association}.#{attribute}"

                associated = Array.wrap(matching_record.send(association)).first

                unless associated
                  raise ArgumentError, "matching_record does not have any elements in association #{association}"
                end

                target = associated
              else
                formatted_operator = attribute.to_s

                target = matching_record
              end

              value = target.send(attribute)

              # need to check for `nil` and not `unless value` as some values may be `false`
              if value.nil?
                association_clause = ''

                if association
                  association_clause = " on first element in association #{association}"
                end

                raise ArgumentError, "matching_record has no value for #{attribute}#{association_clause}"
              end

              "#{formatted_operator}:\"#{value}\""
            }
          }
        end

        let(:matching_record) do
          build_module_instance(matching_module_class)
        end

        let(:non_matching_record) do
          build_module_instance(non_matching_module_class)
        end

        context 'with auxiliary' do
          include_context 'references'
          include_context 'stance'

          let(:attributes_by_association) do
            super().merge(
                actions: [
                    :name
                ]
            )
          end

          let(:module_type) do
            Metasploit::Model::Module::Type::AUX
          end

          it 'should find only matching record' do
            expect(visit).to match_array([matching_record])
          end
        end

        context 'with encoder' do
          include_context 'architectures'

          let(:module_type) do
            Metasploit::Model::Module::Type::ENCODER
          end

          it 'should find only matching record' do
            expect(visit).to match_array([matching_record])
          end
        end

        context 'with exploit' do
          include_context 'references'
          include_context 'stance'
          include_context 'targets'

          let(:attributes_by_association) do
            super().merge(
                targets: [
                    :name
                ]
            )
          end

          let(:module_type) do
            Metasploit::Model::Module::Type::EXPLOIT
          end

          it 'should find only matching record' do
            expect(visit).to match_array([matching_record])
          end
        end

        context 'with nop' do
          include_context 'architectures'

          let(:module_type) do
            Metasploit::Model::Module::Type::NOP
          end

          it 'should find only matching record' do
            expect(visit).to match_array([matching_record])
          end
        end

        context 'with payload' do
          include_context 'architectures'
          include_context 'platforms'

          let(:attributes_by_association) do
            # dups the Hash, but not the Array values.
            payload_attributes_by_association = super().dup

            # Use += so original array is not modified
            payload_attributes_by_association[:module_class] += [:payload_type]

            payload_attributes_by_association
          end

          let(:module_type) do
            Metasploit::Model::Module::Type::PAYLOAD
          end

          it 'should find only matching record' do
            expect(visit).to match_array([matching_record])
          end
        end

        context 'with post' do
          include_context 'architectures'
          include_context 'platforms'
          include_context 'references'

          let(:module_type) do
            Metasploit::Model::Module::Type::POST
          end

          it 'should find only matching record' do
            expect(visit).to match_array([matching_record])
          end
        end
      end
    end
  end

  context '#visitor_by_relation_method' do
    subject(:visitor_by_relation_method) do
      visitor.visitor_by_relation_method
    end

    its([:includes]) { should be_a MetasploitDataModels::Search::Visitor::Includes }
    its([:where]) { should be_a MetasploitDataModels::Search::Visitor::Where }
  end

  context 'visitor_class_by_relation_method' do
    subject(:visitor_class_by_relation_method) do
      described_class.visitor_class_by_relation_method
    end

    its([:includes]) { should == MetasploitDataModels::Search::Visitor::Includes }
    its([:where]) { should == MetasploitDataModels::Search::Visitor::Where }
  end
end