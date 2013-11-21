shared_examples_for 'MetasploitDataModels db/seeds.rb' do
  # undo seeding done for suite
  before(:each) do
    Mdm::Architecture.delete_all
    Mdm::Authority.delete_all
    Mdm::Platform.delete_all
    Mdm::Module::Rank.delete_all
  end

  it 'should seed Mdm::Architecture' do
    expect {
      seed
    }.to change(Mdm::Architecture, :count)
  end

  it 'should seed Mdm::Authority' do
    expect {
      seed
    }.to change(Mdm::Authority, :count)
  end

  it 'should seed Mdm::Platform' do
    expect {
      seed
    }.to change(Mdm::Platform, :count)
  end

  it 'should seed Mdm::Rank' do
    expect {
      seed
    }.to change(Mdm::Module::Rank, :count)
  end

  context 'when run twice' do
    before(:each) do
      seed
    end

    it 'should not raise error' do
      expect {
        seed
      }.to_not raise_error
    end

    it 'should not seed new Mdm::Architectures' do
      expect {
        seed
      }.not_to change(Mdm::Architecture, :count)
    end

    it 'should not seed new Mdm::Authorities' do
      expect {
        seed
      }.not_to change(Mdm::Authority, :count)
    end

    it 'should not seed new Mdm::Platforms' do
      expect {
        seed
      }.not_to change(Mdm::Platform, :count)
    end

    it 'should not seed new Mdm::Ranks' do
      expect {
        seed
      }.not_to change(Mdm::Module::Rank, :count)
    end
  end
end