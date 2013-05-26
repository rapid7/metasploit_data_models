require 'spec_helper'

describe Mdm::SessionEvent do
  context 'associations' do
    it { should belong_to(:session).class_name('Mdm::Session') }
  end
end