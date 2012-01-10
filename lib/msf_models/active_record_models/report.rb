class Report < ActiveRecord::Base
  include Msf::DBManager::DBSave

  belongs_to :workspace
  serialize :options, MsfModels::Base64Serializer.new
end

