require 'spec_helper'

describe Mdm::Authority do
  context 'associations' do
    it { should have_many(:module_instances).class_name('Mdm::Module::Instance').through(:module_references) }
    it { should have_many(:module_references).class_name('Mdm::Module::Reference').through(:references) }
    it { should have_many(:references).class_name('Mdm::Reference').dependent(:destroy) }
    it { should have_many(:vulns).class_name('Mdm::Vuln').through(:vuln_references) }
    it { should have_many(:vuln_references).class_name('Mdm::VulnReference').through(:references) }
  end

  context 'databases' do
    context 'columns' do
      it { should have_db_column(:abbreviation).of_type(:string).with_options(:null => false) }
      it { should have_db_column(:obsolete).of_type(:boolean).with_options(:default => false, :null => false)}
      it { should have_db_column(:summary).of_type(:string).with_options(:null => true) }
      it { should have_db_column(:url).of_type(:text).with_options(:null => true) }
    end

    context 'indices' do
      it { should have_db_index(:abbreviation).unique(true) }
      it { should have_db_index(:summary).unique(true) }
      it { should have_db_index(:url).unique(true) }
    end
  end

  context 'factories' do
    context 'mdm_authority' do
      subject(:mdm_authority) do
        FactoryGirl.build(:mdm_authority)
      end

      it { should be_valid }
    end

    context 'full_mdm_authority' do
      subject(:full_mdm_authority) do
        FactoryGirl.build(:full_mdm_authority)
      end

      it { should be_valid }

      its(:summary) { should_not be_nil }
      its(:url) { should_not be_nil }
    end

    context 'obsolete_mdm_authority' do
      subject(:obsolete_mdm_authority) do
        FactoryGirl.build(:obsolete_mdm_authority)
      end

      it { should be_valid }

      its(:obsolete) { should be_true }
    end
  end

  context 'mass assignment security' do
    it { should allow_mass_assignment_of(:abbreviation) }
    it { should allow_mass_assignment_of(:obsolete) }
    it { should allow_mass_assignment_of(:summary) }
    it { should allow_mass_assignment_of(:url) }
  end

  context 'seeds' do
    it_should_behave_like 'Mdm::Authority seed',
                          :abbreviation => 'BID',
                          :extension_name => 'Mdm::Authority::Bid',
                          :obsolete => false,
                          :summary => 'BuqTraq ID',
                          :url => 'http://www.securityfocus.com/bid'

    it_should_behave_like 'Mdm::Authority seed',
                          :abbreviation => 'CVE',
                          :extension_name => 'Mdm::Authority::Cve',
                          :obsolete => false,
                          :summary => 'Common Vulnerabilities and Exposures',
                          :url => 'http://cvedetails.com'

    it_should_behave_like 'Mdm::Authority seed',
                          :abbreviation => 'MIL',
                          :extension_name => nil,
                          :obsolete => true,
                          :summary => 'milw0rm',
                          :url => 'https://en.wikipedia.org/wiki/Milw0rm'

    it_should_behave_like 'Mdm::Authority seed',
                          :abbreviation => 'MSB',
                          :extension_name => 'Mdm::Authority::Msb',
                          :obsolete => false,
                          :summary => 'Microsoft Security Bulletin',
                          :url => 'http://www.microsoft.com/technet/security/bulletin'

    it_should_behave_like 'Mdm::Authority seed',
                          :abbreviation => 'OSVDB',
                          :extension_name => 'Mdm::Authority::Osvdb',
                          :obsolete => false,
                          :summary => 'Open Sourced Vulnerability Database',
                          :url => 'http://osvdb.org'

    it_should_behave_like 'Mdm::Authority seed',
                          :abbreviation => 'PMASA',
                          :extension_name => 'Mdm::Authority::Pmasa',
                          :obsolete => false,
                          :summary => 'phpMyAdmin Security Announcement',
                          :url => 'http://www.phpmyadmin.net/home_page/security/'

    it_should_behave_like 'Mdm::Authority seed',
                          :abbreviation => 'SECUNIA',
                          :extension_name => 'Mdm::Authority::Secunia',
                          :obsolete => false,
                          :summary => 'Secunia',
                          :url => 'https://secunia.com/advisories'

    it_should_behave_like 'Mdm::Authority seed',
                          :abbreviation => 'US-CERT-VU',
                          :extension_name => 'Mdm::Authority::UsCertVu',
                          :obsolete => false,
                          :summary => 'United States Computer Emergency Readiness Team Vulnerability Notes Database',
                          :url => 'http://www.kb.cert.org/vuls'

    it_should_behave_like 'Mdm::Authority seed',
                          :abbreviation => 'waraxe',
                          :extension_name => 'Mdm::Authority::Waraxe',
                          :obsolete => false,
                          :summary => 'Waraxe Advisories',
                          :url => 'http://www.waraxe.us/content-cat-1.html'
  end

  context 'validations' do
    context 'abbreviation' do
      it { should validate_presence_of(:abbreviation) }
      it { should validate_uniqueness_of(:abbreviation) }
    end
  end
end