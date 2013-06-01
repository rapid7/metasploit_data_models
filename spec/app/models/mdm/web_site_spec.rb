require 'spec_helper'

describe Mdm::WebSite do

  context 'factory' do
    it 'should be valid' do
      web_site = FactoryGirl.build(:mdm_web_site)
      web_site.should be_valid
    end
  end

  context 'database' do

    context 'timestamps'do
      it { should have_db_column(:created_at).of_type(:datetime).with_options(:null => false) }
      it { should have_db_column(:updated_at).of_type(:datetime).with_options(:null => false) }
    end

    context 'columns' do
      it { should have_db_column(:service_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:vhost).of_type(:string) }
      it { should have_db_column(:comments).of_type(:text) }
      it { should have_db_column(:options).of_type(:text) }
    end

    context 'indices' do
      it { should have_db_index(:comments) }
      it { should have_db_index(:options) }
      it { should have_db_index(:vhost) }
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      web_site = FactoryGirl.create(:mdm_web_site)
      expect {
        web_site.destroy
      }.to_not raise_error
      expect {
        web_site.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  context 'associations' do
    it { should belong_to(:service).class_name('Mdm::Service') }
    it { should have_many(:web_forms).class_name('Mdm::WebForm').dependent(:destroy) }
    it { should have_many(:web_pages).class_name('Mdm::WebPage').dependent(:destroy) }
    it { should have_many(:web_vulns).class_name('Mdm::WebVuln').dependent(:destroy) }
  end

  context 'methods' do
    context '#form_count' do
      it 'should return an accurate count of associated Webforms' do
        mysite = FactoryGirl.create(:mdm_web_site)
        FactoryGirl.create(:mdm_web_form, :web_site => mysite)
        FactoryGirl.create(:mdm_web_form, :web_site => mysite)
        mysite.form_count.should == 2
        FactoryGirl.create(:mdm_web_form, :web_site => mysite)
        mysite.form_count.should == 3
      end
    end

    context '#page_count' do
      it 'should return an accurate count of associated Webpages' do
        mysite = FactoryGirl.create(:mdm_web_site)
        FactoryGirl.create(:mdm_web_page, :web_site => mysite)
        FactoryGirl.create(:mdm_web_page, :web_site => mysite)
        mysite.page_count.should == 2
        FactoryGirl.create(:mdm_web_page, :web_site => mysite)
        mysite.page_count.should == 3
      end
    end

    context '#vuln_count' do
      it 'should return an accurate count of associated Webvulns' do
        mysite = FactoryGirl.create(:mdm_web_site)
        FactoryGirl.create(:mdm_web_vuln, :web_site => mysite)
        FactoryGirl.create(:mdm_web_vuln, :web_site => mysite)
        mysite.vuln_count.should == 2
        FactoryGirl.create(:mdm_web_vuln, :web_site => mysite)
        mysite.vuln_count.should == 3
      end
    end
  end
end