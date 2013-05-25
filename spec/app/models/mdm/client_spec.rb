require 'spec_helper'

describe Mdm::Client do

  context 'associations' do
    it { should belong_to(:host).class_name('Mdm::Host') }
  end
end