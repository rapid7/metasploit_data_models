class Task < ActiveRecord::Base
  include Msf::DBManager::DBSave

  belongs_to :workspace

  serialize :options, MsfModels::Base64Serializer.new
  serialize :result, MsfModels::Base64Serializer.new
  serialize :settings, MsfModels::Base64Serializer.new
end

