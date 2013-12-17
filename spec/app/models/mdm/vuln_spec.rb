require 'spec_helper'

describe Mdm::Vuln do
  subject(:vuln) do
    FactoryGirl.build(:mdm_vuln)
  end

  context 'associations' do
    it { should have_many(:exploit_attempts).class_name('Mdm::ExploitAttempt') }
    it { should belong_to(:host).class_name('Mdm::Host') }
    it { should have_many(:module_instances).class_name('Mdm::Module::Instance').through(:module_references) }
    it { should have_many(:module_references).class_name('Mdm::Module::Reference').through(:references) }
    it { should have_many(:references).class_name('Mdm::Reference').through(:vuln_references) }
    it { should belong_to(:service).class_name('Mdm::Service') }
    it { should have_many(:vuln_attempts).class_name('Mdm::VulnAttempt').dependent(:destroy) }
    it { should have_many(:vuln_details).class_name('Mdm::VulnDetail').dependent(:destroy) }
    it { should have_many(:vuln_references).class_name('Mdm::VulnReference').dependent(:destroy) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:exploited_at).of_type(:datetime) }
      it { should have_db_column(:host_id).of_type(:integer) }
      it { should have_db_column(:info).of_type(:string) }
      it { should have_db_column(:name).of_type(:string) }
      it { should have_db_column(:service_id).of_type(:integer) }

      context 'counter caches' do
        it { should have_db_column(:vuln_attempt_count).of_type(:integer).with_options(:default => 0) }
        it { should have_db_column(:vuln_detail_count).of_type(:integer).with_options(:default => 0) }
      end

      context 'timestamps' do
        it { should have_db_column(:created_at).of_type(:datetime) }
        it { should have_db_column(:updated_at).of_type(:datetime) }
      end
    end
  end

  context 'factories' do
    context 'mdm_host_vuln' do
      subject(:mdm_host_vuln) do
        FactoryGirl.build(:mdm_host_vuln)
      end

      it { should be_valid }
    end

    context 'mdm_service_vuln' do
      subject(:mdm_service_vuln) do
        FactoryGirl.build(:mdm_service_vuln)
      end

      it { should be_valid }
    end

    context 'mdm_vuln' do
      subject(:mdm_vuln) do
        FactoryGirl.build(:mdm_vuln)
      end

      it { should be_valid }
    end
  end

  context 'scopes' do
    context 'search' do
      context 'with Mdm::Vuln' do
        subject(:results) do
          described_class.search(query)
        end

        let!(:vuln) do
          FactoryGirl.create(:mdm_vuln)
        end

        context 'with Mdm::Reference' do
          let!(:reference) do
            FactoryGirl.create(:mdm_reference)
          end

          context 'with Mdm::VulnReference' do
            let!(:vuln_ref) do
              FactoryGirl.create(:mdm_vuln_reference, :reference => reference, :vuln => vuln)
            end

            context 'with query matching Mdm::Reference#designation' do
              let(:query) do
                reference.designation
              end

              it 'should match Mdm::Vuln' do
                results.should =~ [vuln]
              end
            end

            context 'with query matching Mdm::Reference#designation' do
              let(:query) do
                "Not #{reference.designation}"
              end

              it 'should not match Mdm::Vuln' do
                results.should be_empty
              end
            end
          end

          context 'without Mdm::VulnReference' do
            context 'with query matching Mdm::Vuln#name' do
              let(:query) do
                vuln.name
              end

              it 'should match Mdm::Vuln' do
                results.should =~ [vuln]
              end
            end

            context 'with query not matching Mdm::Vuln#name' do
              let(:query) do
                "Not #{vuln.name}"
              end

              it 'should not match Mdm::Vuln' do
                results.should be_empty
              end
            end

            context 'with query matching Mdm::Vuln#info' do
              let(:query) do
                vuln.info
              end

              it 'should match Mdm::Vuln' do
                results.should =~ [vuln]
              end
            end

            context 'without query matching Mdm::Vuln#info' do
              let(:query) do
                "Not #{vuln.info}"
              end

              it 'should not match Mdm::Vuln' do
                results.should be_empty
              end
            end
          end
        end
      end
    end
  end

  context 'validations' do
    it { should validate_presence_of :name }

    context "invalid" do
      let(:mdm_vuln) do
        FactoryGirl.build(:mdm_vuln)
      end

      it "should not allow :name over 255 characters" do
        str = Faker::Lorem.characters(256)
        mdm_vuln.name = str
        mdm_vuln.valid?
        mdm_vuln.errors[:name][0].should include "is too long"
      end
    end
  end

  context '#destroy' do
    let!(:vuln) do
      FactoryGirl.create(:mdm_vuln)
    end

    let!(:vuln_attempt) do
      FactoryGirl.create(
          :mdm_vuln_attempt,
          :vuln => vuln
      )
    end

    let!(:vuln_detail) do
      FactoryGirl.create(
          :mdm_vuln_detail,
          :vuln => vuln
      )
    end

    let!(:vuln_reference) do
      FactoryGirl.create(
          :mdm_vuln_reference,
          :vuln => vuln
      )
    end

    context 'before' do
      it 'should have 1 Mdm::Vuln' do
        Mdm::Vuln.count.should == 1
      end

      it 'should have 1 Mdm::VulnAttempt' do
        Mdm::VulnAttempt.count.should == 1
      end

      it 'should have 1 Mdm::VulnDetail' do
        Mdm::VulnDetail.count.should == 1
      end

      it 'should have 1 Mdm::VulnReference' do
        Mdm::VulnReference.count.should == 1
      end
    end

    context 'after' do
      it 'should delete 1 Mdm::Vuln' do
        expect {
          vuln.destroy
        }.to change(Mdm::Vuln, :count).by(-1)
      end

      it 'should delete 1 Mdm::VulnAttempt' do
        expect {
          vuln.destroy
        }.to change(Mdm::VulnAttempt, :count).by(-1)
      end

      it 'should delete 1 Mdm::VulnDetail' do
        expect {
          vuln.destroy
        }.to change(Mdm::VulnDetail, :count).by(-1)
      end

      it 'should delete 1 Mdm::VulnReference' do
        expect {
          vuln.destroy
        }.to change(Mdm::VulnReference, :count).by(-1)
      end
    end
  end
end