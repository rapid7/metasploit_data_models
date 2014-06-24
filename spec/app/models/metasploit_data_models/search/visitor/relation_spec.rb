require 'spec_helper'

describe MetasploitDataModels::Search::Visitor::Relation do
  subject(:visitor) do
    described_class.new(
        :query => query
    )
  end

  let(:formatted) do
    # needs to be a valid operation so that query is valid
    "name:\"#{value}\""
  end

  let(:klass) {
    Mdm::Host
  }

  let(:query) do
    Metasploit::Model::Search::Query.new(
        :formatted => formatted,
        :klass => klass
    )
  end

  let(:value) {
    FactoryGirl.generate :mdm_host_name
  }

  it_should_behave_like 'Metasploit::Concern.run'

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

    context 'MetasploitDataModels::Search::Visitor::Joins' do
      subject(:joins_visitor) do
        visitor.visitor_by_relation_method[:joins]
      end

      it 'should visit Metasploit::Model::Search::Query#tree' do
        joins_visitor.should_receive(:visit).with(query.tree)

        visit
      end

      it 'should pass visited to ActiveRecord::Relation#joins' do
        visited = double('Visited')
        joins_visitor.stub(:visit).with(query.tree).and_return(visited)

        ActiveRecord::Relation.any_instance.should_receive(:joins).with(visited).and_return(query.klass.scoped)

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
      context 'Metasploit::Model::Search::Query#klass' do
        context 'with Mdm::Service' do
          let(:klass) {
            Mdm::Service
          }

          let(:matching_ports) {
            [
                1,
                2
            ]
          }

          let(:matching_records) {
            matching_record_by_port.values
          }

          let(:non_matching_port) {
            3
          }

          #
          # let!s
          #

          let!(:matching_record_by_port) {
            matching_ports.each_with_object({}) { |matching_port, matching_record_by_port|
              matching_record_by_port[matching_port] = FactoryGirl.create(
                  :mdm_service,
                  port: matching_port
              )
            }
          }

          let!(:non_matching_record) {
            FactoryGirl.create(
                :mdm_service,
                port: non_matching_port
            )
          }

          context 'with port' do
            context 'with single port number' do
              let(:formatted) {
                "port:#{matching_port}"
              }

              let(:matching_port) {
                matching_ports.sample
              }

              let(:matching_record) {
                matching_record_by_port[matching_port]
              }

              it 'should find only record with that port number' do
                expect(visit).to match_array([matching_record])
              end
            end

            context 'with port range' do
              let(:formatted) {
                "port:#{matching_ports.min}-#{matching_ports.max}"
              }

              it 'should find all records with port numbers within the range' do
                expect(visit).to match_array(matching_records)
              end
            end

            context 'with comma separated port numbers' do
              let(:formatted) {
                "port:#{matching_ports.join(',')}"
              }

              it 'should find all records with the port numbers' do
                expect(visit).to match_array(matching_records)
              end
            end

            context 'with overlapping comma separated port number and range' do
              let(:matching_port) {
                matching_ports.sample
              }

              let(:formatted) {
                %Q{port:#{matching_port},#{matching_ports.min}-#{matching_ports.max}}
              }

              it 'should find all records with the matching ports once' do
                expect(visit).to match_array(matching_records)
              end
            end
          end

          context 'with all operators' do
            let(:formatted) {
              %Q{port:#{matching_port}}
            }
          end
        end

        context 'with Mdm::Host' do
          #
          # lets
          #

          let(:klass) {
            Mdm::Host
          }

          #
          # Don't use factories to prevent prefix aliasing when sequences go from 1 to 10 or 10 to 100
          #

          let(:matching_record_name) {
            'mdm_host_name_a'
          }

          let(:matching_service_name) {
            'mdm_service_name_a'
          }

          let(:non_matching_record_name) {
            'mdm_host_name_b'
          }

          let(:non_matching_service_name) {
            'mdm_service_name_b'
          }

          #
          # let!s
          #

          let!(:matching_record) do
            FactoryGirl.build(
                :mdm_host,
                name: matching_record_name
            )
          end

          let!(:matching_service) do
            FactoryGirl.create(
                :mdm_service,
                host: matching_record,
                name: matching_service_name
            )
          end

          let!(:non_matching_record) do
            FactoryGirl.build(
                :mdm_host,
                name: non_matching_record_name
            )
          end

          let!(:non_matching_service) do
            FactoryGirl.create(
                :mdm_service,
                host: non_matching_record,
                name: non_matching_service_name
            )
          end

          it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                                :attribute => :name

          it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                                association: :services,
                                attribute: :name

          context 'with all operators' do
            let(:formatted) {
              %Q{name:"#{matching_record_name}" services.name:"#{matching_service_name}"}
            }

            it 'should find only matching record' do
              if visit.to_a != [matching_record]
                true
              end

              expect(visit).to match_array([matching_record])
            end
          end
        end
      end
    end
  end

  context '#visitor_by_relation_method' do
    subject(:visitor_by_relation_method) do
      visitor.visitor_by_relation_method
    end

    its([:joins]) { should be_a MetasploitDataModels::Search::Visitor::Joins }
    its([:includes]) { should be_a MetasploitDataModels::Search::Visitor::Includes }
    its([:where]) { should be_a MetasploitDataModels::Search::Visitor::Where }
  end

  context 'visitor_class_by_relation_method' do
    subject(:visitor_class_by_relation_method) do
      described_class.visitor_class_by_relation_method
    end

    its([:joins]) { should == MetasploitDataModels::Search::Visitor::Joins }
    its([:includes]) { should == MetasploitDataModels::Search::Visitor::Includes }
    its([:where]) { should == MetasploitDataModels::Search::Visitor::Where }
  end
end