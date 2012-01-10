class Listener < ActiveRecord::Base
  include Msf::DBManager::DBSave
  include MsfModels::SharedValidations

  belongs_to :workspace
  belongs_to :task

  serialize :options, MsfModels::Base64Serializer.new
  validates_presence_of :address
  validates_ip_address :address
  validates_presence_of :port
end

