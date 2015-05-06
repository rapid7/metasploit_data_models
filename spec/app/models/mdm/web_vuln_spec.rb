require 'spec_helper'

describe Mdm::WebVuln do
  let(:confidence_range) do
    0 .. 100
  end

  let(:default_params) do
    []
  end

  let(:methods) do
    [
        'GET',
        'POST',
        # XXX not sure why PATH is valid since it's not an HTTP method verb.
        'PATH'
    ]
  end

  let(:risk_range) do
    0 .. 5
  end

  subject(:web_vuln) do
    described_class.new
  end

  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { should belong_to(:web_site).class_name('Mdm::WebSite') }
  end

  context 'CONSTANTS' do
    it 'should define CONFIDENCE_RANGE' do
      described_class::CONFIDENCE_RANGE.should == confidence_range
    end

    it 'should define METHODS in any order' do
      described_class::METHODS.should =~ methods
    end

    it 'should define RISK_RANGE' do
      described_class::RISK_RANGE.should == risk_range
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      web_vuln = FactoryGirl.create(:mdm_web_vuln)
      expect {
        web_vuln.destroy
      }.to_not raise_error
      expect {
        web_vuln.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:blame).of_type(:text) }
      it { should have_db_column(:category).of_type(:text).with_options(:null => false) }
      it { should have_db_column(:confidence).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:description).of_type(:text) }
      it { should have_db_column(:method).of_type(:string).with_options(:limit => 1024, :null => false) }
      it { should have_db_column(:name).of_type(:string).with_options(:limit => 1024, :null => false) }
      it { should have_db_column(:owner).of_type(:string) }
      it { should have_db_column(:params).of_type(:text).with_options(:null => false) }
      it { should have_db_column(:path).of_type(:text).with_options(:null => false) }
      it { should have_db_column(:payload).of_type(:text) }
      it { should have_db_column(:pname).of_type(:text) }
      it { should have_db_column(:proof).of_type(:binary).with_options(:null => false) }
      it { should have_db_column(:query).of_type(:text) }
      it { should have_db_column(:request).of_type(:binary) }
      it { should have_db_column(:risk).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:web_site_id).of_type(:integer).with_options(:null => false) }

      context 'timestamps' do
        it { should have_db_column(:created_at).of_type(:datetime).with_options(:null => false) }
        it { should have_db_column(:updated_at).of_type(:datetime).with_options(:null => false) }
      end
    end

    context 'indices' do
      it { should have_db_index(:method) }
      it { should have_db_index(:name) }
      it { should have_db_index(:path) }
    end
  end

  context 'factories' do
    context 'mdm_web_vuln' do
      subject(:mdm_web_vuln) do
        FactoryGirl.build(:mdm_web_vuln)
      end

      it { should be_valid }

      context 'after reloading' do
        before(:each) do
          mdm_web_vuln.save!
          mdm_web_vuln.reload
        end

        it { should be_valid }
      end
    end
  end

  context 'validations' do
    it { should validate_presence_of :category }
    it { should validate_inclusion_of(:confidence).in_range(confidence_range) }
    it { should validate_inclusion_of(:method).in_array(methods) }
    it { should validate_presence_of :name }
    it { should validate_presence_of :path }

    context 'params' do
      it 'should not validate presence of params because it default to [] and can never be nil' do
        web_vuln.should_not validate_presence_of(:params)
      end

      context 'validates parameters' do
        let(:type_signature_sentence) do
          "Valid parameters are an Array<Array(String, String)>."
        end

        it 'should validate params is an Array' do
          web_vuln.params = ''

          web_vuln.params.should_not be_an Array
          web_vuln.should_not be_valid
          web_vuln.errors[:params].should include(
                                              "is not an Array.  #{type_signature_sentence}"
                                          )
        end

        it 'should allow empty Array' do
          web_vuln.params = []
          web_vuln.valid?

          web_vuln.errors[:params].should be_empty
        end

        context 'with bad element' do
          let(:index) do
            web_vuln.params.index(element)
          end

          before(:each) do
            web_vuln.params = [element]
          end

          context 'without Array' do
            let(:element) do
              {}
            end

            it 'should not be an Array' do
              web_vuln.params.first.should_not be_an Array
            end

            it 'should validate elements of params are Arrays' do
              web_vuln.should_not be_valid
              web_vuln.errors[:params].should include(
                                                  "has non-Array at index #{index} (#{element.inspect}).  " \
                                                  "#{type_signature_sentence}"
                                              )
            end
          end

          context 'with element length < 2' do
            let(:element) do
              ['']
            end

            it 'should have length < 2' do
              web_vuln.params.first.length.should < 2
            end

            it 'should validate elements of params are not too short' do
              web_vuln.should_not be_valid
              web_vuln.errors[:params].should include(
                                                  "has too few elements at index #{index} (#{element.inspect}).  " \
                                                  "#{type_signature_sentence}"
                                              )
            end
          end

          context 'with element length > 2' do
            let(:element) do
              ['', '', '']
            end

            it 'should have length > 2' do
              web_vuln.params.first.length.should > 2
            end

            it 'should validate elements of params are not too long' do
              web_vuln.should_not be_valid
              web_vuln.errors[:params].should include(
                                                  "has too many elements at index #{index} (#{element.inspect}).  " \
                                                  "#{type_signature_sentence}"
                                              )
            end
          end

          context 'parameter name' do
            let(:element) do
              [parameter_name, 'parameter_value']
            end

            context 'with String' do
              context 'with blank' do
                let(:parameter_name) do
                  ''
                end

                it 'should have blank parameter name' do
                  web_vuln.params.first.first.should be_empty
                end

                it 'should validate that parameter name is not empty' do
                  web_vuln.should_not be_valid
                  web_vuln.errors[:params].should include(
                                                      "has blank parameter name at index #{index} " \
                                                      "(#{element.inspect}).  " \
                                                      "#{type_signature_sentence}"
                                                  )
                end
              end
            end

            context 'without String' do
              let(:parameter_name) do
                :parameter_name
              end

              it 'should not have String for parameter name' do
                web_vuln.params.first.first.should_not be_a String
              end

              it 'should validate that parameter name is a String' do
                web_vuln.should_not be_valid
                web_vuln.errors[:params].should include(
                                                    "has non-String parameter name (#{parameter_name.inspect}) " \
                                                    "at index #{index} (#{element.inspect}).  " \
                                                    "#{type_signature_sentence}"
                                                )
              end
            end
          end

          context 'parameter value' do
            let(:element) do
              ['parameter_name', parameter_value]
            end

            context 'without String' do
              let(:parameter_value) do
                0
              end

              it 'should not have String for parameter name' do
                web_vuln.params.first.second.should_not be_a String
              end

              it 'should validate that parameter value is a String' do
                web_vuln.should_not be_valid
                web_vuln.errors[:params].should include(
                                                    "has non-String parameter value (#{parameter_value}) " \
                                                    "at index #{index} (#{element.inspect}).  " \
                                                    "#{type_signature_sentence}"
                                                )
              end
            end
          end
        end
      end
    end

    it { should validate_presence_of :proof }
    it { should validate_inclusion_of(:risk).in_range(risk_range) }
    it { should validate_presence_of :web_site }
  end

  context 'serializations' do
    it { should serialize(:params).as_instance_of(MetasploitDataModels::Base64Serializer) }
  end

  context '#params' do
    let(:default) do
      []
    end

    let(:params) do
      web_vuln.params
    end

    it 'should default to []' do
      params.should == default
    end

    it 'should return default if set to nil' do
      web_vuln.params = nil
      web_vuln.params.should == default
    end

    it 'should return default if set to nil and saved' do
      web_vuln = FactoryGirl.build(:mdm_web_vuln)
      web_vuln.params = nil
      web_vuln.save!

      web_vuln.params.should == default
    end
  end
end