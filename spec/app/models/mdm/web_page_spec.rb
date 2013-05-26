require 'spec_helper'

describe Mdm::WebPage do

  context 'associations' do
    it { should belong_to(:web_site).class_name('Mdm::WebSite') }
  end
end