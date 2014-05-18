require 'spec_helper'

describe Mdm::HostTag do

  context 'associations' do
    it { should belong_to(:host).class_name('Mdm::Host') }
    it { should belong_to(:tag).class_name('Mdm::Tag') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:host_id).of_type(:integer) }
      it { should have_db_column(:tag_id).of_type(:integer) }
    end
  end

  context 'factories' do
    context 'mdm_host_tag' do
      subject(:mdm_host_tag) do
        FactoryGirl.build(:mdm_host_tag)
      end

      it { should be_valid }
    end
  end

  context '#destroy' do
    let(:tag) do
      FactoryGirl.create(
          :mdm_tag
      )
    end

    let!(:host_tag) do
      FactoryGirl.create(
          :mdm_host_tag,
          :tag => tag
      )
    end

    it 'should delete 1 Mdm::HostTag' do
      expect {
        host_tag.destroy
      }.to change(Mdm::HostTag, :count).by(-1)
    end

    context 'with multiple Mdm::HostTags using same Mdm::Tag' do
      let!(:other_host_tag) do
        FactoryGirl.create(
            :mdm_host_tag,
            :tag => tag
        )
      end

      it 'should not delete Mdm::Tag' do
        expect {
          host_tag.destroy
        }.to_not change(Mdm::Tag, :count)
      end
    end

    context 'with only one Mdm::HostTag using Mdm::Tag' do
      it 'should delete Mdm::Tag' do
        expect {
          host_tag.destroy
        }.to change(Mdm::Tag, :count).by(-1)
      end
    end
  end
end