require 'spec_helper'

describe MetasploitDataModels::IPAddress::V4::NMAP::Segment::Range do
  subject(:range) {
    described_class.new(
        value: formatted_value
    )
  }

  #
  # Shared examples
  #

  shared_examples_for 'extreme' do |extreme|
    context "##{extreme}" do
      subject("range_#{extreme}") {
        range.send(extreme)
      }

      before(:each) do
        allow(range).to receive(:value).and_return(value)
      end

      context 'with #value' do
        context 'with Range' do
          let(:value) {
            Range.new(0, 1)
          }

          it "is Range##{extreme} of #value" do
            expect(send("range_#{extreme}")).to eq(value.send(extreme))
          end
        end

        context 'without Range' do
          let(:value) {
            'invalid_value'
          }

          it { should be_nil }
        end
      end

      context 'without #value' do
        let(:value) {
          nil
        }

        it { should be_nil }
      end
    end
  end

  #
  # lets
  #

  let(:formatted_value) {
    nil
  }

  context 'CONSTANTS' do
    context 'SEPARATOR' do
      subject(:separator) {
        described_class::SEPARATOR
      }

      it { should == '-' }
    end
  end

  context 'validations' do
    #
    # lets
    #

    let(:presence_error) {
      I18n.translate!('errors.messages.blank')
    }

    let(:invalid_error) {
      I18n.translate!('errors.messages.invalid')
    }

    #
    # Callbacks
    #

    before(:each) do
      range.valid?
    end

    context 'errors on #begin' do
      subject(:begin_errors) {
        range.errors[:begin]
      }

      context '#begin' do
        context 'with nil' do
          let(:formatted_value) {
            nil
          }

          it { should include presence_error }
        end

        context 'with MetasploitDataModels::IPAddress::V4::NMAP::Segment::Number' do
          context 'with valid' do
            let(:formatted_value) {
              '1-256'
            }

            it { should_not include invalid_error }
          end

          context 'without valid' do
            let(:formatted_value) {
              '256-257'
            }

            it { should include invalid_error }
          end
        end
      end
    end

    context 'errors on #end' do
      subject(:end_errors) {
        range.errors[:end]
      }

      context '#end' do
        context 'with nil' do
          let(:formatted_value) {
            nil
          }

          it { should include presence_error }
        end

        context 'with MetasploitDataModels::IPAddress::V4::NMAP::Segment::Number' do
          context 'with valid' do
            let(:formatted_value) {
              '256-1'
            }

            it { should_not include invalid_error }
          end

          context 'without valid' do
            let(:formatted_value) {
              '257-256'
            }

            it { should include invalid_error }
          end
        end
      end
    end

    context 'errors on #value' do
      subject(:value_errors) {
        range.errors[:value]
      }

      let(:error) {
        I18n.translate!(
            'metasploit.model.errors.models.metasploit_data_models/ip_address/v4/nmap/segment/range.attributes.value.order',
            begin: range.begin,
            end: range.end
        )
      }

      context 'with nil' do
        let(:formatted_value) {
          nil
        }

        it { should_not include error }
      end

      context 'with incomparables' do
        let(:formatted_value) {
          'a-1'
        }

        it { should_not include error }
      end

      context 'with numbers' do
        context 'in order' do
          let(:formatted_value) {
            '1-2'
          }

          it { should_not include error }
        end

        context 'out of order' do
          let(:formatted_value) {
            '2-1'
          }

          it { should include error }
        end
      end
    end
  end

  it_should_behave_like 'extreme', :begin
  it_should_behave_like 'extreme', :end

  context '#value' do
    subject(:value) {
      range.value
    }

    context 'with -' do
      context 'with extremes' do
        let(:formatted_value) {
          '1-2'
        }

        it { should be_a Range }

        context 'Range#begin' do
          subject(:range_begin) {
            value.begin
          }

          it { should be_a MetasploitDataModels::IPAddress::V4::NMAP::Segment::Number }

          context 'MetasploitDataModels::IPAddress::V4::NMAP::Segment::Number#value' do
            it "is value before '-'" do
              expect(range_begin.value).to eq(1)
            end
          end
        end

        context 'Range#end' do
          subject(:range_end) {
            value.end
          }

          it { should be_a MetasploitDataModels::IPAddress::V4::NMAP::Segment::Number }

          context 'MetasploitDataModels::IPAddress::V4::NMAP::Segment::Number#value' do
            it "is value after '-'" do
              expect(range_end.value).to eq(2)
            end
          end
        end
      end

      context 'without extremes' do
        let(:formatted_value) {
          '-'
        }

        it { should be_a Range }

        context 'Range#begin' do
          subject(:range_begin) {
            value.begin
          }

          it { should be_a MetasploitDataModels::IPAddress::V4::NMAP::Segment::Number }

          context 'MetasploitDataModels::IPAddress::V4::NMAP::Segment::Number#value' do
            subject(:begin_value) {
              range_begin.value
            }

            it { should == '' }
          end
        end

        context 'Range#end' do
          subject(:range_end) {
            value.end
          }

          it { should be_a MetasploitDataModels::IPAddress::V4::NMAP::Segment::Number }

          context 'MetasploitDataModels::IPAddress::V4::NMAP::Segment::Number#value' do
            subject(:end_value) {
              range_end.value
            }

            it { should == '' }
          end
        end
      end
    end

    context 'without -' do
      let(:formatted_value) do
        '1'
      end

      it { should_not be_a Range }
    end
  end
end