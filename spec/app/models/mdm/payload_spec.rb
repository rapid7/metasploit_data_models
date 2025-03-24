RSpec.describe Mdm::Payload, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'factory' do
    it 'should be valid' do
      mdm_payload = FactoryBot.build(:mdm_payload)
      expect(mdm_payload).to be_valid
    end
  end

  context 'database' do

    context 'timestamps'do
      it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
      it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
    end

    context 'columns' do
      it { is_expected.to have_db_column(:name).of_type(:string) }
      it { is_expected.to have_db_column(:uuid).of_type(:string) }
      it { is_expected.to have_db_column(:uuid_mask).of_type(:integer) }
      it { is_expected.to have_db_column(:timestamp).of_type(:integer) }
      it { is_expected.to have_db_column(:arch).of_type(:string) }
      it { is_expected.to have_db_column(:platform).of_type(:string) }
      it { is_expected.to have_db_column(:urls).of_type(:string) }
      it { is_expected.to have_db_column(:description).of_type(:string) }
      it { is_expected.to have_db_column(:raw_payload).of_type(:string) }
      it { is_expected.to have_db_column(:raw_payload_hash).of_type(:string) }
      it { is_expected.to have_db_column(:build_status).of_type(:string) }
      it { is_expected.to have_db_column(:build_opts).of_type(:string) }
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      payload = FactoryBot.create(:mdm_payload)
      expect {
        payload.destroy
      }.to_not raise_error
      expect {
        payload.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
