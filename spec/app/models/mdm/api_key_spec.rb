require 'spec_helper'

describe Mdm::ApiKey do
  context 'database' do
    context 'columns' do
      it { should have_db_column(:token).of_type(:text).with_options(:null => false) }

      context 'timestamps' do
        it { should have_db_column(:created_at).of_type(:datetime).with_options(:null => false) }
        it { should have_db_column(:updated_at).of_type(:datetime).with_options(:null => false) }
      end
    end

    context 'indices' do
      it { should have_db_index(:token).unique(true) }
    end
  end

  context 'validations' do
    context 'supports_api' do
      subject(:api_key) do
        FactoryGirl.build(:mdm_api_key)
      end

      let(:error) do
        'is not available because license does not support API access'
      end

      context 'with License defined' do
        let(:license_class) do
          mock('License', :instance => license_singleton)
        end

        let(:license_singleton) do
          mock('License Singleton', :supports_api? => false)
        end

        before(:each) do
          stub_const('License', license_class)
        end

        it 'should call License.instance to get singleton' do
          License.should_receive(:instance).and_return(license_singleton)

          api_key.valid?
        end

        context 'with supports api' do
          before(:each) do
            license_singleton.stub(:supports_api? => true)
          end

          it { should be_valid }
        end

        context 'without supports api' do
          before(:each) do
            license_singleton.stub(:supports_api? => false)
          end

          it 'should record error' do
            api_key.valid?

            api_key.errors[:base].should include(error)
          end
        end
      end

      context 'without License defined' do
        it 'should record error' do
          api_key.valid?

          api_key.errors[:base].should include(error)
        end
      end
    end

    context 'token' do
      it { should ensure_length_of(:token).is_at_least(8) }
      it { should validate_uniqueness_of :token }
    end
  end
end