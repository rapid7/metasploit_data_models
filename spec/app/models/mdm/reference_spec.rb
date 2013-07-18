require 'spec_helper'

describe Mdm::Reference do
  context 'associations' do
    it { should belong_to(:authority).class_name('Mdm::Authority') }
    it { should have_many(:hosts).class_name('Mdm::Host').through(:vulns) }
    it { should have_many(:module_instances).class_name('Mdm::Module::Instance').through(:module_references) }
    it { should have_many(:module_references).class_name('Mdm::Module::Reference').dependent(:destroy) }
    it { should have_many(:services).class_name('Mdm::Service').through(:vulns) }
    it { should have_many(:vulns).class_name('Mdm::Vuln').through(:vuln_references) }
    it { should have_many(:vuln_references).class_name('Mdm::VulnReference').dependent(:destroy) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:authority_id).of_type(:integer).with_options(:null => true) }
      it { should have_db_column(:designation).of_type(:string).with_options(:null => true) }
      it { should have_db_column(:url).of_type(:text).with_options(:null => true) }
    end

    context 'indices' do
      it { should have_db_index([:authority_id, :designation]).unique(true) }
      it { should have_db_index([:url]).unique(true) }
    end
  end

  context 'derivation' do
    subject(:reference) do
      FactoryGirl.build(
          :mdm_reference,
          :authority => authority,
          :designation => designation
      )
    end

    def attribute_type(attribute)
      column = base_class.columns_hash.fetch(attribute.to_s)

      column.type
    end

    let(:base_class) do
      described_class
    end

    context 'with authority' do
      let(:authority) do
        Mdm::Authority.where(:abbreviation => abbreviation).first
      end

      context 'with abbreviation' do
        context 'BID' do
          let(:abbreviation) do
            'BID'
          end

          let(:designation) do
            FactoryGirl.generate :mdm_reference_bid_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'CVE' do
          let(:abbreviation) do
            'CVE'
          end

          let(:designation) do
            FactoryGirl.generate :mdm_reference_cve_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'MSB' do
          let(:abbreviation) do
            'MSB'
          end

          let(:designation) do
            FactoryGirl.generate :mdm_reference_msb_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'OSVDB' do
          let(:abbreviation) do
            'OSVDB'
          end

          let(:designation) do
            FactoryGirl.generate :mdm_reference_osvdb_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'PMASA' do
          let(:abbreviation) do
            'PMASA'
          end

          let(:designation) do
            FactoryGirl.generate :mdm_reference_pmasa_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'SECUNIA' do
          let(:abbreviation) do
            'SECUNIA'
          end

          let(:designation) do
            FactoryGirl.generate :mdm_reference_secunia_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'US-CERT-VU' do
          let(:abbreviation) do
            'US-CERT-VU'
          end

          let(:designation) do
            FactoryGirl.generate :mdm_reference_us_cert_vu_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'waraxe' do
          let(:abbreviation) do
            'waraxe'
          end

          let(:designation) do
            FactoryGirl.generate :mdm_reference_waraxe_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end
      end
    end
  end

  context 'factories' do
    context 'mdm_reference' do
      subject(:mdm_reference) do
        FactoryGirl.build(:mdm_reference)
      end

      it { should be_valid }

      its(:authority) { should_not be_nil }
      its(:designation) { should_not be_nil }
      its(:url) { should_not be_nil }
    end

    context 'obsolete_mdm_reference' do
      subject(:obsolete_mdm_reference) do
        FactoryGirl.build(:obsolete_mdm_reference)
      end

      it { should be_valid }

      its(:authority) { should_not be_nil }
      its(:designation) { should_not be_nil }
      its(:url) { should be_nil }
    end

    context 'url_mdm_reference' do
      subject(:url_mdm_reference) do
        FactoryGirl.build(:url_mdm_reference)
      end

      it { should be_valid }

      its(:authority) { should be_nil }
      its(:designation) { should be_nil }
      its(:url) { should_not be_nil }
    end
  end

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of(:authority_id) }
    it { should allow_mass_assignment_of(:designation) }
    it { should allow_mass_assignment_of(:url) }
  end

  context 'validations' do
    subject(:reference) do
      FactoryGirl.build(
          :mdm_reference,
          :authority => authority,
          :designation => designation,
          :url => url
      )
    end

    context 'with authority' do
      let(:authority) do
        FactoryGirl.create(
            :mdm_authority
        )
      end

      context 'with designation' do
        let(:designation) do
          FactoryGirl.generate :mdm_reference_designation
        end

        context 'with url' do
          let(:url) do
            FactoryGirl.generate :mdm_reference_url
          end

          it { should be_valid }
        end

        context 'without url' do
          let(:url) do
            nil
          end

          it { should be_valid }
        end
      end

      context 'without designation' do
        let(:designation) do
          nil
        end

        context 'with url' do
          let(:url) do
            FactoryGirl.generate :mdm_reference_url
          end

          it { should be_invalid }

          it 'should record error on designation' do
            reference.valid?

            reference.errors[:designation].should include("can't be blank")
          end

          it 'should not record error on url' do
            reference.valid?

            reference.errors[:url].should be_empty
          end
        end

        context 'without url' do
          let(:url) do
            nil
          end

          it { should be_invalid }

          it 'should record error on designation' do
            reference.valid?

            reference.errors[:designation].should include("can't be blank")
          end

          it 'should not record error on url' do
            reference.valid?

            reference.errors[:url].should be_empty
          end
        end
      end
    end

    context 'without authority' do
      let(:authority) do
        nil
      end

      context 'with designation' do
        let(:designation) do
          FactoryGirl.generate :mdm_reference_designation
        end

        let(:url) do
          nil
        end

        it { should be_invalid }

        it 'should record error on designation' do
          reference.valid?

          reference.errors[:designation].should include('must be nil')
        end
      end

      context 'without designation' do
        let(:designation) do
          nil
        end

        context 'with url' do
          let(:url) do
            FactoryGirl.generate :mdm_reference_url
          end

          it { should be_valid }
        end

        context 'without url' do
          let(:url) do
            nil
          end

          it { should be_invalid }

          it 'should record error on url' do
            reference.valid?

            reference.errors[:url].should include("can't be blank")
          end
        end
      end
    end
  end

  context '#derived_url' do
    subject(:derived_url) do
      reference.derived_url
    end

    let(:reference) do
      FactoryGirl.build(
          :mdm_reference,
          :authority => authority,
          :designation => designation
      )
    end

    context 'with authority' do
      let(:authority) do
        mock_model(Mdm::Authority)
      end

      context 'with blank designation' do
        let(:designation) do
          ''
        end

        it { should be_nil }
      end

      context 'without blank designation' do
        let(:designation) do
          '31337'
        end

        it 'should call Mdm::Authority#designation_url' do
          authority.should_receive(:designation_url).with(designation)

          derived_url
        end
      end
    end

    context 'without authority' do
      let(:authority) do
        nil
      end

      let(:designation) do
        nil
      end

      it { should be_nil }
    end
  end

  context '#authority?' do
    subject(:authority?) do
      reference.authority?
    end

    let(:reference) do
      FactoryGirl.build(
          :mdm_reference,
          :authority => authority
      )
    end

    context 'with authority' do
      let(:authority) do
        FactoryGirl.create(:mdm_authority)
      end

      it { should be_true }
    end

    context 'without authority' do
      let(:authority) do
        nil
      end

      it { should be_false }
    end
  end
end