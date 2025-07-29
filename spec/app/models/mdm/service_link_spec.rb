RSpec.describe Mdm::ServiceLink, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'factory' do
    it 'should be valid' do
      service_link = FactoryBot.build(:mdm_service_link)
      expect(service_link).to be_valid
    end
  end

  context 'database' do

    context 'timestamps'do
      it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(:null => false) }
      it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(:null => false) }
    end

    context 'columns' do
      it { is_expected.to have_db_column(:parent_id).of_type(:integer).with_options(:null => false) }
      it { is_expected.to have_db_column(:child_id).of_type(:integer).with_options(:null => false) }
    end
  end

  context '#destroy' do
    it 'should successfully destroy one Mdm::ServiceLink' do
      service_link = FactoryBot.create(:mdm_service_link)
      expect { service_link.destroy }.to_not raise_error
      expect { service_link.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'with one parent and one child' do
      let(:parent_service1) { FactoryBot.create(:mdm_service, name: 'parent_service1') }
      let(:child_service1) { FactoryBot.create(:mdm_service, name: 'child_service1') }
      let!(:service_link1) { FactoryBot.create(:mdm_service_link, parent: parent_service1, child: child_service1) }

      it 'should only destroy the child service' do
        expect { service_link1.destroy }.to_not raise_error
        expect { service_link1.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { child_service1.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { parent_service1.reload }.to_not raise_error(ActiveRecord::RecordNotFound)
      end

      context 'with multiple children' do
        let(:child_service2) { FactoryBot.create(:mdm_service, name: 'child_service2') }
        let!(:service_link2) { FactoryBot.create(:mdm_service_link, parent: parent_service1, child: child_service2) }

        it 'should only destroy the child service related to this service link' do
          expect { service_link1.destroy }.to_not raise_error
          expect { service_link1.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { service_link2.reload }.to_not raise_error(ActiveRecord::RecordNotFound)
          expect { child_service1.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { child_service2.reload }.to_not raise_error(ActiveRecord::RecordNotFound)
          expect { parent_service1.reload }.to_not raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'with multiple nested children' do
        let(:child_service2) { FactoryBot.create(:mdm_service, name: 'child_service2') }
        let!(:service_link2) { FactoryBot.create(:mdm_service_link, parent: child_service1, child: child_service2) }

        it 'should only destroy the nested child services and service links' do
          expect { service_link1.destroy }.to_not raise_error
          expect { service_link1.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { service_link2.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { child_service1.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { child_service2.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { parent_service1.reload }.to_not raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'with a child that has another parent' do
        let(:parent_service2) { FactoryBot.create(:mdm_service, name: 'parent_service2') }
        let!(:service_link2) { FactoryBot.create(:mdm_service_link, parent: parent_service2, child: child_service1) }

        it 'should not destroy the child' do
          expect { service_link1.destroy }.to_not raise_error
          expect { service_link1.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { service_link2.reload }.to_not raise_error(ActiveRecord::RecordNotFound)
          expect { child_service1.reload }.to_not raise_error(ActiveRecord::RecordNotFound)
          expect { parent_service1.reload }.to_not raise_error(ActiveRecord::RecordNotFound)
          expect { parent_service2.reload }.to_not raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

  context "Associations" do
    it { is_expected.to belong_to(:parent).class_name('Mdm::Service') }
    it { is_expected.to belong_to(:child).class_name('Mdm::Service') }
  end

  context "validations" do
    it "should not allow duplicate associations" do
      parent_service = FactoryBot.build(:mdm_service)
      child_service = FactoryBot.build(:mdm_service)
      FactoryBot.create(:mdm_service_link, :parent => parent_service, :child => child_service)
      service_link2 = FactoryBot.build(:mdm_service_link, :parent => parent_service, :child => child_service)
      expect(service_link2).not_to be_valid
    end
  end

  context 'callbacks' do
    context 'before_destroy' do
      it 'should call #destroy_orphan_child' do
        service_link = FactoryBot.create(:mdm_service_link)
        expect(service_link).to receive(:destroy_orphan_child)
        service_link.destroy
      end
    end
  end

end
