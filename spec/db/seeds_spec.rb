require 'spec_helper'

describe 'db/seeds.rb' do
  def seed
    load MetasploitDataModels.root.join('db', 'seeds.rb')
  end

  it_should_behave_like 'MetasploitDataModels db/seeds.rb'
end