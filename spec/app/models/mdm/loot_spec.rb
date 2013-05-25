require 'spec_helper'

describe Mdm::Loot do
   context 'associations' do
     it { should belong_to(:workspace).class_name('Mdm::Workspace') }
     it { should belong_to(:service).class_name('Mdm::Service') }
     it { should belong_to(:host).class_name('Mdm::Host') }
   end

   context 'scopes' do
     context 'search' do
       it 'should match on ltype' do
         myloot = FactoryGirl.create(:mdm_loot, :ltype => 'find.this.ltype')
         Mdm::Loot.search('find.this.ltype').should include(myloot)
       end

       it 'should match on name' do
         myloot = FactoryGirl.create(:mdm_loot, :name => 'Find This')
         Mdm::Loot.search('Find This').should include(myloot)
       end

       it 'should match on info' do
         myloot = FactoryGirl.create(:mdm_loot, :info => 'Find This')
         Mdm::Loot.search('Find This').should include(myloot)
       end
     end
   end
end