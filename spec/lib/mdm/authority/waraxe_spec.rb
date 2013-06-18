require 'spec_helper'

describe Mdm::Authority::Waraxe do
  context 'CONSTANTS' do
    context 'DESIGNATION_REGEXP' do
      subject(:designation_regexp) do
        described_class::DESIGNATION_REGEXP
      end

      let(:designation) do
        FactoryGirl.generate :mdm_reference_waraxe_designation
      end

      it 'should match sequence' do
        designation.should match(designation_regexp)
      end
    end
  end

  context 'designation_url' do
    subject(:designation_url) do
      described_class.designation_url(designation)
    end

    context 'with designation that matches DESIGNATION_URL' do
      let(:designation) do
        "#{year}-SA##{number}"
      end

      let(:number) do
        103
      end

      let(:year) do
        2013
      end

      it 'should be under bid directory' do
        designation_url.should == "http://www.waraxe.us/advisory-#{number}.html"
      end
    end

    context 'without designation that matches DESIGNATION_URL' do
      let(:designation) do
        '#103'
      end

      it { should be_nil }
    end
  end
end