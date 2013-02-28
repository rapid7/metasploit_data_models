require 'spec_helper'

describe Mdm::WebVuln do
  context 'associations' do
    it { should belong_to(:web_site).class_name('Mdm::WebSite') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:blame).of_type(:text) }
      it { should have_db_column(:category).of_type(:text) }
      it { should have_db_column(:confidence).of_type(:text) }
      it { should have_db_column(:description).of_type(:text) }
      it { should have_db_column(:method).of_type(:string).with_options(:limit => 1024) }
      it { should have_db_column(:name).of_type(:string).with_options(:limit => 1024) }
      it { should have_db_column(:params).of_type(:text) }
      it { should have_db_column(:path).of_type(:text) }
      it { should have_db_column(:payload).of_type(:text) }
      it { should have_db_column(:pname).of_type(:text) }
      it { should have_db_column(:proof).of_type(:binary) }
      it { should have_db_column(:query).of_type(:text) }
      it { should have_db_column(:request).of_type(:binary) }
      it { should have_db_column(:risk).of_type(:integer) }
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

  context 'serializations' do
    it { should serialize(:params).as_instance_of(MetasploitDataModels::Base64Serializer) }
  end
end