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
      let!(:matching_record) do
        FactoryGirl.create(:full_mdm_module_instance)
      end

      let!(:non_matching_record) do
        FactoryGirl.create(:full_mdm_module_instance)
      end

      it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                            :attribute => :description

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

        let!(:matching_record) do
          FactoryGirl.create(:stanced_full_mdm_module_instance)
        end

        let!(:non_matching_record) do
          FactoryGirl.create(:stanced_full_mdm_module_instance)
        end

        it 'should find only matching record' do
          expect(visit).to match_array([matching_record])
        end
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
                            :attribute => :stance do
        let!(:matching_record) do
          FactoryGirl.create(:stanced_full_mdm_module_instance)
        end

        let!(:non_matching_record) do
          FactoryGirl.create(:stanced_full_mdm_module_instance)
        end
      end

      it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                            :association => :actions,
                            :attribute => :name do
        let!(:matching_record) do
          FactoryGirl.create(
              :full_mdm_module_instance,
              :module_type => module_type
          )
        end

        let!(:non_matching_record) do
          FactoryGirl.create(
              :full_mdm_module_instance,
              :module_type => module_type
          )
        end

        # Only auxiliary modules have actions
        let(:module_type) do
          Metasploit::Model::Module::Type::AUX
        end
      end

      context 'with distinct architectures' do
        #
        # let!s
        #

        let!(:matching_record) do
          FactoryGirl.create(
              :full_mdm_module_instance,
              :architecture_count => 0
          ).tap { |module_instance|
            FactoryGirl.create(
                :mdm_module_architecture,
                :architecture => matching_architecture,
                :module_instance => module_instance
            )
          }
        end

        let!(:non_matching_record) do
          FactoryGirl.create(
              :full_mdm_module_instance,
              :architecture_count => 0
          ).tap { |module_instance|
            FactoryGirl.create(
                :mdm_module_architecture,
                :architecture => non_matching_architecture,
                :module_instance => module_instance
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
      end

      context 'with references' do
        let!(:matching_record) do
          FactoryGirl.create(
              :full_mdm_module_instance,
              :reference_count => 1
          )
        end

        let!(:non_matching_record) do
          FactoryGirl.create(
              :full_mdm_module_instance,
              :reference_count => 1
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
      end

      it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                            :association => :authors,
                            :attribute => :name

      context 'with email addresses' do
        #
        # let!s
        #

        let!(:matching_record) do
          FactoryGirl.create(
              :full_mdm_module_instance,
              :author_count => 0
          ).tap { |module_instance|
            FactoryGirl.create(
                # full_mdm_module_author has an email_address
                :full_mdm_module_author,
                :module_instance => module_instance
            )
          }
        end

        let!(:non_matching_record) do
          FactoryGirl.create(
              :full_mdm_module_instance,
              :author_count => 0
          ).tap { |module_instance|
            FactoryGirl.create(
                # full_mdm_module_author has an email_address
                :full_mdm_module_author,
                :module_instance => module_instance
            )
          }
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
                            :attribute => :module_type

      it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                            :association => :module_class,
                            :attribute => :payload_type do
        #
        # lets
        #

        let(:module_type) do
          Metasploit::Model::Module::Type::PAYLOAD
        end

        #
        # let!s
        #

        let!(:matching_record) do
          FactoryGirl.create(
              :full_mdm_module_instance,
              :module_type => module_type
          )
        end

        let!(:non_matching_record) do
          FactoryGirl.create(
              :full_mdm_module_instance,
              :module_type => module_type
          )
        end
      end

      context 'with exploit' do
        #
        # lets
        #

        let(:module_type) do
          Metasploit::Model::Module::Type::EXPLOIT
        end

        #
        # let!s
        #

        let!(:matching_record) do
          FactoryGirl.create(
              :full_mdm_module_instance,
              :module_type => module_type
          )
        end

        let!(:non_matching_record) do
          FactoryGirl.create(
              :full_mdm_module_instance,
              :module_type => module_type
          )
        end

        it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                              :association => :platforms,
                              :attribute => :name

        it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                              :association => :targets,
                              :attribute => :name

        it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record with Metasploit::Model::Search::Operator::Deprecated::Platform',
                              :name => :os

        it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record with Metasploit::Model::Search::Operator::Deprecated::Platform',
                              :name => :platform
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

        let(:architecture_count) do
          1
        end

        let(:formatted) do
          "text:\"#{value}\""
        end

        let(:module_type) do
          FactoryGirl.generate :metasploit_model_module_type
        end

        let(:reference_count) do
          0
        end

        #
        # let!s
        #

        let!(:matching_record) do
          FactoryGirl.create(
              :full_mdm_module_instance,
              :module_type => module_type,
              :architecture_count => architecture_count,
              :reference_count => reference_count
          )
        end

        let!(:non_matching_record) do
          FactoryGirl.create(
              :full_mdm_module_instance,
              :module_type => module_type,
              :architecture_count => architecture_count,
              :reference_count => reference_count
          )
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

        context 'with Mdm::Module::Instance#actions' do
          let(:module_type) do
            Metasploit::Model::Module::Type::AUX
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

        context 'with Mdm::Architecture#abbreviation' do
          #
          # lets
          #

          let(:architecture_count) do
            # Manually create architectures to ensure that the matching_record's abbreviation is not a substring of the
            # non_matching_record's abbreviation as architectures.abbreviation is a string column, and so matched with
            # ILIKE.
            0
          end

          let(:matching_architecture) do
            Mdm::Architecture.where(:abbreviation => matching_architecture_abbreviation).first
          end

          let(:matching_architecture_abbreviation) do
            'java'
          end

          let(:non_matching_architecture) do
            Mdm::Architecture.where(:abbreviation => non_matching_architecture_abbreviation).first
          end

          let(:non_matching_architecture_abbreviation) do
            'ruby'
          end

          let(:value) do
            matching_architecture_abbreviation
          end

          #
          # let!s
          #

          let!(:matching_module_architecture) do
            FactoryGirl.create(
                :mdm_module_architecture,
                :architecture => matching_architecture,
                :module_instance => matching_record
            )
          end

          let!(:non_matching_module_architecture) do
            FactoryGirl.create(
                :mdm_module_architecture,
                :architecture => non_matching_architecture,
                :module_instance => non_matching_record
            )
          end

          it 'should find only matching record' do
            expect(visit).to match_array([matching_record])
          end
        end

        context 'with Mdm::Module::Instance#platforms and Mdm::Module::Instance#targets' do
          let(:module_type) do
            Metasploit::Model::Module::Type::EXPLOIT
          end

          context 'with Mdm::Platform#name' do
            let(:value) do
              matching_record.platforms.sample.name
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

        context 'with Mdm::Module::Instance#references' do
          let(:matching_reference) do
            matching_record.references.sample
          end

          let(:reference_count) do
            1
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

      context 'with all operators' do
        #
        # lets
        #

        let(:full_architectures) do
          table = Mdm::Architecture.arel_table

          Mdm::Architecture.where(
              table[:bits].not_eq(nil).and(
                  table[:endianness].not_eq(nil)
              )
          ).order(table[:abbreviation].asc)
        end

        let(:formatted) do
          formatted_operations.join(' ')
        end

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
              :architectures => [
                  :abbreviation,
                  :bits,
                  :endianness,
                  :family
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
              ],
              :references => [
                  :designation,
                  :url
              ]
          }
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

        #
        # let!s
        #

        let!(:matching_record) do
          FactoryGirl.create(
              :full_mdm_module_instance,
              # manually create architectures to ensure all attributes are set
              :architecture_count => 0,
              # manually create authors
              :author_count => 0,
              :module_type => module_type,
              # ensure at least one reference, since can be 0+ by default
              :reference_count => 1
          ).tap { |module_instance|
            FactoryGirl.create(
                # full author has an email address
                :full_mdm_module_author,
                :module_instance => module_instance
            )

            FactoryGirl.create(
                :mdm_module_architecture,
                :architecture => full_architectures.first,
                :module_instance => module_instance
            )
          }
        end

        let!(:non_matching_record) do
          FactoryGirl.create(
              :full_mdm_module_instance,
              # manually create architectures to ensure all attributes are set
              :architecture_count => 0,
              # manually create authors
              :author_count => 0,
              :module_type => module_type,
              # ensure at least one reference, since can be 0+ by default
              :reference_count => 1
          ).tap { |module_instance|
            FactoryGirl.create(
                # full author has an email address
                :full_mdm_module_author,
                :module_instance => module_instance
            )

            FactoryGirl.create(
                :mdm_module_architecture,
                :architecture => full_architectures.last,
                :module_instance => module_instance
            )
          }
        end

        context 'with auxiliary' do
          let(:attributes_by_association) do
            auxiliary_attributes_by_association = super().dup

            auxiliary_attributes_by_association[nil] += [:stance]
            auxiliary_attributes_by_association[:actions] = [:name]

            auxiliary_attributes_by_association
          end

          let(:module_type) do
            Metasploit::Model::Module::Type::AUX
          end

          it 'should find only matching record' do
            expect(visit).to match_array([matching_record])
          end
        end

        context 'with encoder' do
          let(:module_type) do
            Metasploit::Model::Module::Type::ENCODER
          end

          it 'should find only matching record' do
            expect(visit).to match_array([matching_record])
          end
        end

        context 'with exploit' do
          let(:attributes_by_association) do
            exploit_attributes_by_association = super().dup

            exploit_attributes_by_association[nil] += [:stance]
            exploit_attributes_by_association[:platforms] = [:name]
            exploit_attributes_by_association[:targets] = [:name]

            exploit_attributes_by_association
          end

          let(:module_type) do
            Metasploit::Model::Module::Type::EXPLOIT
          end

          it 'should find only matching record' do
            expect(visit).to match_array([matching_record])
          end
        end

        context 'with nop' do
          let(:module_type) do
            Metasploit::Model::Module::Type::NOP
          end

          it 'should find only matching record' do
            expect(visit).to match_array([matching_record])
          end
        end

        context 'with payload' do
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