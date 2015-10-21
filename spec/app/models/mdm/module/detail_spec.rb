RSpec.describe Mdm::Module::Detail, type: :model do
  subject(:detail) do
    FactoryGirl.build(
        :mdm_module_detail,
        :mtype => mtype,
        :stance => stance
    )
  end

  let(:mtype) do
    FactoryGirl.generate :mdm_module_detail_mtype
  end

  let(:ranks) do
    [
        0,
        100,
        200,
        300,
        400,
        500,
        600
    ]
  end

  let(:stance) do
    FactoryGirl.generate :mdm_module_detail_stance
  end

  let(:stances) do
    [
        'aggressive',
        'passive'
    ]
  end

  let(:types) do
    [
        'auxiliary',
        'encoder',
        'exploit',
        'nop',
        'payload',
        'post'
    ]
  end

  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to have_many(:actions).class_name('Mdm::Module::Action').dependent(:destroy) }
    it { is_expected.to have_many(:archs).class_name('Mdm::Module::Arch').dependent(:destroy) }
    it { is_expected.to have_many(:authors).class_name('Mdm::Module::Author').dependent(:destroy) }
    it { is_expected.to have_many(:mixins).class_name('Mdm::Module::Mixin').dependent(:destroy) }
    it { is_expected.to have_many(:platforms).class_name('Mdm::Module::Platform').dependent(:destroy) }
    it { is_expected.to have_many(:refs).class_name('Mdm::Module::Ref').dependent(:destroy) }
    it { is_expected.to have_many(:targets).class_name('Mdm::Module::Target').dependent(:destroy) }
  end

  context 'CONSTANTS' do
    context 'DIRECTORY_BY_TYPE' do
      subject(:directory_by_type) do
        described_class::DIRECTORY_BY_TYPE
      end

      it "maps 'auxiliary' to 'auxiliary'" do
        expect(directory_by_type['auxiliary']).to eq('auxiliary')
      end
      
      it "maps 'encoder' to 'encoders'" do
        expect(directory_by_type['encoder']).to eq('encoders')
      end
      
      it "maps 'exploit' to 'exploits'" do
        expect(directory_by_type['exploit']).to eq('exploits')
      end
      
      it "maps 'nop' to 'nops'" do
        expect(directory_by_type['nop']).to eq('nops')
      end
      
      it "maps 'payload' to 'payloads'" do
        expect(directory_by_type['payload']).to eq('payloads')
      end
      
      it "maps 'post' to 'post'" do
        expect(directory_by_type['post']).to eq('post')
      end
    end

    context 'PRIVILEGES' do
      subject(:privileges) do
        described_class::PRIVILEGES
      end

      it 'should contain both Boolean values' do
        expect(privileges).to include(false)
        expect(privileges).to include(true)
      end
    end

    context 'RANK_BY_NAME' do
      subject(:rank_by_name) do
        described_class::RANK_BY_NAME
      end

      it "maps 'Manual' to 0" do
        expect(rank_by_name['Manual']).to eq(0)
      end

      it "maps 'Low' to 100" do
        expect(rank_by_name['Low']).to eq(100)
      end

      it "maps 'Average' to 200" do
        expect(rank_by_name['Average']).to eq(200)
      end

      it "maps 'Normal' to 300" do
        expect(rank_by_name['Normal']).to eq(300)
      end

      it "maps 'Good' to 400" do
        expect(rank_by_name['Good']).to eq(400)
      end

      it "maps 'Great' to 500" do
        expect(rank_by_name['Great']).to eq(500)
      end

      it "maps 'Excellent' to 600" do
        expect(rank_by_name['Excellent']).to eq(600)
      end
    end

    context 'STANCES' do
      subject(:stances) do
        described_class::STANCES
      end

      it { is_expected.to include('aggressive') }
      it { is_expected.to include('passive') }
    end
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:default_target).of_type(:integer) }
      it { is_expected.to have_db_column(:description).of_type(:text) }
      it { is_expected.to have_db_column(:disclosure_date).of_type(:datetime)}
      it { is_expected.to have_db_column(:file).of_type(:text) }
      it { is_expected.to have_db_column(:fullname).of_type(:text) }
      it { is_expected.to have_db_column(:license).of_type(:string) }
      it { is_expected.to have_db_column(:mtime).of_type(:datetime) }
      it { is_expected.to have_db_column(:mtype).of_type(:string) }
      it { is_expected.to have_db_column(:name).of_type(:text) }
      it { is_expected.to have_db_column(:privileged).of_type(:boolean) }
      it { is_expected.to have_db_column(:rank).of_type(:integer) }
      it { is_expected.to have_db_column(:ready).of_type(:boolean) }
      it { is_expected.to have_db_column(:refname).of_type(:text) }
      it { is_expected.to have_db_column(:stance).of_type(:string).with_options(:null => true) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:description) }
      it { is_expected.to have_db_index(:mtype) }
      it { is_expected.to have_db_index(:name) }
      it { is_expected.to have_db_index(:refname) }
    end
  end

  context 'factories' do
    context 'mdm_module_detail' do
      subject(:mdm_module_detail) do
        FactoryGirl.build(:mdm_module_detail)
      end

      it { is_expected.to be_valid }

      context 'stance' do
        subject(:mdm_module_detail) do
          FactoryGirl.build(:mdm_module_detail, :mtype => mtype)
        end

        context 'with supports_stance?' do
          let(:mtype) do
            'exploit'
          end

          it { is_expected.to be_valid }

          context '#stance' do
            subject(:stance) {
              mdm_module_detail.stance
            }

            it { is_expected.not_to be_nil }
          end

          context '#supports_stance?' do
            subject(:supports_stance?) {
              mdm_module_detail.supports_stance?
            }

            it { is_expected.to eq(true) }
          end
        end

        context 'without supports_stance?' do
          let(:mtype) do
            'post'
          end

          it { is_expected.to be_valid }

          context '#stance' do
            subject(:stance) {
              mdm_module_detail.stance
            }

            it { is_expected.to be_nil }
          end

          context '#supports_stance?' do
            subject(:supports_stance?) {
              mdm_module_detail.supports_stance?
            }

            it { is_expected.to eq(false) }
          end
        end
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_inclusion_of(:mtype).in_array(types) }

    # Because the boolean field will cast most strings to false,
    # validate_inclusion_of(:privileged).in_array([true, false]) will fail on the disallowed values check.

    context 'rank' do
      it 'validates rank is only an integer', pending: 'https://github.com/thoughtbot/shoulda-matchers/issues/784' do
        is_expected.to validate_numericality_of(:rank).only_integer
      end

      it { is_expected.to validate_inclusion_of(:rank).in_array(ranks) }
    end

    it { is_expected.to validate_presence_of(:refname) }

    context 'stance' do
      context 'mtype' do
        it_should_behave_like 'Mdm::Module::Detail supports stance with mtype', 'auxiliary'
        it_should_behave_like 'Mdm::Module::Detail supports stance with mtype', 'exploit'

        it_should_behave_like 'Mdm::Module::Detail does not support stance with mtype', 'encoder'
        it_should_behave_like 'Mdm::Module::Detail does not support stance with mtype', 'nop'
        it_should_behave_like 'Mdm::Module::Detail does not support stance with mtype', 'payload'
        it_should_behave_like 'Mdm::Module::Detail does not support stance with mtype', 'post'
      end
    end
  end

  context 'with saved' do
    before(:each) do
      detail.save!
    end

    context '#add_action' do
      def add_action
        detail.add_action(name)
      end

      let(:name) do
        FactoryGirl.generate :mdm_module_action_name
      end

      it 'should add an Mdm::Action under the Mdm::ModuleDetail' do
        expect {
          add_action
        }.to change(detail.actions, :length).by(1)
      end

      context 'new Mdm::Action' do
        subject(:module_action) do
          add_action

          detail.actions.last
        end

        it { is_expected.to be_valid }

        context '#name' do
          it 'is name passed to add_action' do
            expect(module_action.name).to eq(name)
          end
        end
      end
    end

    context '#add_arch' do
      def add_arch
        detail.add_arch(name)
      end

      let(:name) do
        FactoryGirl.generate :mdm_module_arch_name
      end

      it 'should add an Mdm::ModuleArch under the Mdm::ModuleDetail' do
        expect {
          add_arch
        }.to change(detail.archs, :length).by(1)
      end

      context 'new Mdm::ModuleArch' do
        subject(:module_arch) do
          add_arch

          detail.archs.last
        end

        it { is_expected.to be_valid }

        context '#name' do
          it 'is name passed to add_arch' do
            expect(module_arch.name).to eq(name)
          end
        end
      end
    end

    context '#add_author' do
      let(:name) do
        FactoryGirl.generate :mdm_module_author_name
      end

      context 'with email' do
        def add_author
          detail.add_author(name, email)
        end

        let(:email) do
          FactoryGirl.generate :mdm_module_author_email
        end

        it 'should add an Mdm::ModuleAuthor under the Mdm::ModuleDetail' do
          expect {
            add_author
          }.to change(detail.authors, :length).by(1)
        end

        context 'new Mdm::ModuleAuthor' do
          subject(:module_author) do
            add_author

            detail.authors.last
          end

          it { is_expected.to be_valid }

          context '#email' do
            it 'is email passed to add_author' do
              expect(module_author.email).to eq(email)
            end
          end

          context '#name' do
            it 'is name passed to add_author' do
              expect(module_author.name).to eq(name)
            end
          end
        end
      end

      context 'without email' do
        def add_author
          detail.add_author(name)
        end

        it 'should add an Mdm::ModuleAuthor under the Mdm::ModuleDetail' do
          expect {
            add_author
          }.to change(detail.authors, :length).by(1)
        end

        context 'new Mdm::ModuleAuthor' do
          subject(:module_author) do
            add_author

            detail.authors.last
          end

          it { is_expected.to be_valid }

          context '#email' do
            subject(:module_author_email) {
              module_author.email
            }

            it { is_expected.to be_nil }
          end

          context '#name' do
            it 'is name passed to add_author' do
              expect(module_author.name).to eq(name)
            end
          end
        end
      end
    end

    context '#add_mixin' do
      def add_mixin
        detail.add_mixin(name)
      end

      let(:name) do
        FactoryGirl.generate :mdm_module_mixin_name
      end

      it 'should add an Mdm::ModuleMixin under the Mdm::ModuleDetail' do
        expect {
          add_mixin
        }.to change(detail.mixins, :length).by(1)
      end

      context 'new Mdm::ModuleMixin' do
        subject(:mdm_module_mixin) do
          add_mixin

          detail.mixins.last
        end

        it { is_expected.to be_valid }

        context '#name' do
          it 'is name passed to add_mixin' do
            expect(mdm_module_mixin.name).to eq(name)
          end
        end
      end
    end

    context '#add_platform' do
      def add_platform
        detail.add_platform(name)
      end

      let(:name) do
        FactoryGirl.generate :mdm_module_platform_name
      end

      it 'should add an Mdm::ModulePlatform under the Mdm::ModuleDetail' do
        expect {
          add_platform
        }.to change(detail.platforms, :length).by(1)
      end

      context 'new Mdm::ModulePlatform' do
        subject(:module_platform) do
          add_platform

          detail.platforms.last
        end

        it { is_expected.to be_valid }

        context '#name' do
          it 'is name passed to add_platform' do
            expect(module_platform.name).to eq(name)
          end
        end
      end
    end

    context '#add_ref' do
      def add_ref
        detail.add_ref(name)
      end

      let(:name) do
        FactoryGirl.generate :mdm_module_ref_name
      end

      it 'should add an Mdm::ModuleRef under the Mdm::ModuleDetail' do
        expect {
          add_ref
        }.to change(detail.refs, :length).by(1)
      end

      context 'new Mdm::ModuleRef' do
        subject(:module_ref) do
          add_ref

          detail.refs.last
        end

        it { is_expected.to be_valid }

        context '#name' do
          it 'is name passed to add_ref' do
            expect(module_ref.name).to eq(name)
          end
        end
      end
    end

    context '#add_target' do
      def add_target
        detail.add_target(index, name)
      end

      let(:index) do
        FactoryGirl.generate :mdm_module_target_index
      end

      let(:name) do
        FactoryGirl.generate :mdm_module_target_name
      end

      it 'should add an Mdm::ModuleTarget under the Mdm::ModuleDetail' do
        expect {
          add_target
        }.to change(detail.targets, :length).by(1)
      end

      context 'new Mdm::ModuleTarget' do
        subject(:module_target) do
          add_target

          detail.targets.last
        end

        it { is_expected.to be_valid }

        context '#name' do
          it 'is name passed to add_target' do
            expect(module_target.name).to eq(name)
          end
        end
      end
    end
  end
end
