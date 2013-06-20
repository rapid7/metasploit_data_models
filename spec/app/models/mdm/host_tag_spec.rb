require 'spec_helper'

describe Mdm::HostTag do
  context 'associations' do
    it { should belong_to(:host).class_name('Mdm::Host') }
    it { should belong_to(:tag).class_name('Mdm::Tag') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:host_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:tag_id).of_type(:integer).with_options(:null => false) }
    end

    context 'indices' do
      context 'foreign keys' do
        it { should have_db_index(:host_id) }
        it { should have_db_index(:tag_id) }
      end

      context 'unique' do
        it { should have_db_index([:host_id, :tag_id]).unique(true) }
      end
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

  context 'validations' do
    it { should validate_presence_of :host }
    it { should validate_presence_of :tag }

    # Can't use validate_uniqueness_of(:tag_id).scoped_to(:host_id) because it will attempt to
    # INSERT with NULL host_id, which is invalid.
    context 'validate uniqueness of tag_id scoped to host_id' do
      let(:existing_host) do
        FactoryGirl.create(:mdm_host)
      end

      let(:existing_tag) do
        FactoryGirl.create(:mdm_tag)
      end

      let!(:existing_host_tag) do
        FactoryGirl.create(
            :mdm_host_tag,
            :host => existing_host,
            :tag => existing_tag
        )
      end

      context 'with same host_id' do
        subject(:new_host_tag) do
          FactoryGirl.build(
              :mdm_host_tag,
              :host => existing_host,
              :tag => existing_tag
          )
        end

        it { should_not be_valid }

        it 'should record error on tag_id' do
          new_host_tag.valid?

          new_host_tag.errors[:tag_id].should include('has already been taken')
        end
      end

      context 'without same host_id' do
        subject(:new_host_tag) do
          FactoryGirl.build(
              :mdm_host_tag,
              :host => new_host,
              :tag => existing_tag
          )
        end

        let(:new_host) do
          FactoryGirl.create :mdm_host
        end

        it { should be_valid }
      end
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