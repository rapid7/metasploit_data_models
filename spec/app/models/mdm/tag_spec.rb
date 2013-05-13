require 'spec_helper'

describe Mdm::Tag do
  context 'factories' do
    context 'mdm_tag' do
      subject(:mdm_tag) do
        FactoryGirl.build(:mdm_tag)
      end

      it { should be_valid }
    end
  end
end