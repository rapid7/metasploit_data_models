class User < ActiveRecord::Base
  include Msf::DBManager::DBSave

  serialize :prefs, MsfModels::Base64Serializer.new
end

