require 'spec_helper'

describe Mdm::WmapTarget do
  it_should_behave_like 'Metasploit::Concern.run'

  it_should_behave_like 'coerces inet column type to string', :address
end