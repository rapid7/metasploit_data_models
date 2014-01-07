require 'spec_helper'

describe Mdm::Session do

  context 'factory' do
    it 'should be valid' do
      session = FactoryGirl.build(:mdm_session)
      session.should be_valid
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      session = FactoryGirl.create(:mdm_session)
      expect {
        session.destroy
      }.to_not raise_error
      expect {
        session.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:architecture_id).of_type(:integer) }
      it { should have_db_column(:datastore).of_type(:text) }
      it { should have_db_column(:desc).of_type(:string) }
      it { should have_db_column(:host_id).of_type(:integer) }
      it { should have_db_column(:local_id).of_type(:integer) }
      it { should have_db_column(:platform_id).of_type(:integer) }
      it { should have_db_column(:port).of_type(:integer) }
      it { should have_db_column(:stype).of_type(:string) }
      it { should have_db_column(:via_exploit).of_type(:string) }
      it { should have_db_column(:via_payload).of_type(:string) }

      context 'timestamps'do
        it { should have_db_column(:closed_at).of_type(:datetime) }
        it { should have_db_column(:last_seen).of_type(:datetime) }
        it { should have_db_column(:opened_at).of_type(:datetime).with_options(:null => false) }
      end
    end

    context 'indices' do
      it { should have_db_index(:architecture_id) }
      it { should have_db_index(:platform_id) }
    end
  end

  context 'associations' do
    it { should belong_to(:architecture).class_name('Mdm::Architecture') }
    it { should have_many(:events).class_name('Mdm::SessionEvent').dependent(:delete_all) }
    it { should have_one(:exploit_attempt).class_name('Mdm::ExploitAttempt') }
    it { should belong_to(:host).class_name('Mdm::Host') }
    it { should belong_to(:platform).class_name('Mdm::Platform') }
    it { should have_many(:routes).class_name('Mdm::Route').dependent(:destroy) }
    it { should have_many(:tasks).class_name('Mdm::Task').through(:task_sessions) }
    it { should have_many(:task_sessions).class_name('Mdm::TaskSession').dependent(:destroy) }
    it { should have_one(:vuln_attempt).class_name('Mdm::VulnAttempt') }
    it { should have_one(:workspace).class_name('Mdm::Workspace').through(:host) }
  end

  context 'scopes' do
    context 'alive' do
      it 'should return sessions that have not been closed' do
        alive_session = FactoryGirl.create(:mdm_session)
        dead_session = FactoryGirl.create(:mdm_session, :closed_at => Time.now)
        alive_set = Mdm::Session.alive
        alive_set.should include(alive_session)
        alive_set.should_not include(dead_session)
      end
    end

    context 'dead'  do
      it 'should return sessions that have been closed' do
        alive_session = FactoryGirl.create(:mdm_session)
        dead_session = FactoryGirl.create(:mdm_session, :closed_at => Time.now)
        dead_set = Mdm::Session.dead
        dead_set.should_not include(alive_session)
        dead_set.should include(dead_session)
      end
    end

    context 'upgradeable' do
      subject(:upgradeable) do
        described_class.upgradeable
      end

      #
      # lets
      #

      let(:platform) do
        Mdm::Platform.where(fully_qualified_name: platform_fully_qualified_name).first
      end

      #
      # let!s
      #

      let!(:session) do
        FactoryGirl.create(
            :mdm_session,
            closed_at: closed_at,
            platform: platform,
            stype: stype
        )
      end

      context 'with closed' do
        let(:closed_at) do
          Time.now.utc
        end

        context 'with meterpreter' do
          let(:stype) do
            'meterpreter'
          end

          context 'with Windows' do
            let(:platform_fully_qualified_name) do
              'Windows'
            end

            it 'does not include session' do
              expect(upgradeable).not_to include(session)
            end
          end

          context 'with Windows descendant' do
            let(:platform_fully_qualified_name) do
              'Windows XP'
            end

            it 'does not include session' do
              expect(upgradeable).not_to include(session)
            end
          end

          context 'without Windows' do
            let(:platform_fully_qualified_name) do
              'Linux'
            end

            it 'does not include session' do
              expect(upgradeable).not_to include(session)
            end
          end
        end

        context 'with shell' do
          let(:stype) do
            'shell'
          end

          context 'with Windows' do
            let(:platform_fully_qualified_name) do
              'Windows'
            end

            it 'does not include session' do
              expect(upgradeable).not_to include(session)
            end
          end

          context 'with Windows descendant' do
            let(:platform_fully_qualified_name) do
              'Windows XP'
            end

            it 'does not include session' do
              expect(upgradeable).not_to include(session)
            end
          end

          context 'without Windows' do
            let(:platform_fully_qualified_name) do
              'Linux'
            end

            it 'does not include session' do
              expect(upgradeable).not_to include(session)
            end
          end
        end
      end

      context 'without closed' do
        let(:closed_at) do
          nil
        end

        context 'with meterpreter' do
          let(:stype) do
            'meterpreter'
          end

          context 'with Windows' do
            let(:platform_fully_qualified_name) do
              'Windows'
            end

            it 'does not include session' do
              expect(upgradeable).not_to include(session)
            end
          end

          context 'with Windows descendant' do
            let(:platform_fully_qualified_name) do
              'Windows XP'
            end

            it 'does not include session' do
              expect(upgradeable).not_to include(session)
            end
          end

          context 'without Windows' do
            let(:platform_fully_qualified_name) do
              'Linux'
            end

            it 'does not include session' do
              expect(upgradeable).not_to include(session)
            end
          end
        end

        context 'with shell' do
          let(:stype) do
            'shell'
          end

          context 'with Windows' do
            let(:platform_fully_qualified_name) do
              'Windows'
            end

            it 'includes session' do
              expect(upgradeable).to include(session)
            end
          end

          context 'with Windows descendant' do
            let(:platform_fully_qualified_name) do
              'Windows XP'
            end

            it 'includes session' do
              expect(upgradeable).to include(session)
            end
          end

          context 'without Windows' do
            let(:platform_fully_qualified_name) do
              'Linux'
            end

            it 'does not include session' do
              expect(upgradeable).not_to include(session)
            end
          end
        end
      end
    end
  end

  context 'callbacks' do
    context 'before_destroy' do
      it 'should call #stop' do
        mysession = FactoryGirl.create(:mdm_session)
        mysession.should_receive(:stop)
        mysession.destroy
      end
    end
  end

  context 'validations' do
    it { should validate_presence_of :architecture }
    it { should validate_presence_of :platform }
  end

  context '#upgradeable?' do
    subject(:upgradeable?) do
      session.upgradeable?
    end

    let(:session) do
      FactoryGirl.create(
          :mdm_session,
          platform: platform,
          stype: stype
      )
    end

    context 'with shell' do
      let(:platform) do
        Mdm::Platform.where(fully_qualified_name: platform_fully_qualified_name).first
      end

      let(:stype) do
        'shell'
      end

      context 'with Windows' do
        let(:platform_fully_qualified_name) do
          'Windows'
        end

        it { should be_true }
      end

      context 'with Windows descendant' do
        let(:platform_fully_qualified_name) do
          'Windows XP'
        end

        it { should be_true }
      end

      context 'without Windows' do
        let(:platform_fully_qualified_name) do
          'Linux'
        end

        it { should be_false }
      end
    end

    context 'with meterpreter' do
      let(:platform) do
        FactoryGirl.generate :mdm_platform
      end

      let(:stype) do
        'meterpreter'
      end

      it { should be_false }
    end
  end
end