module MsfModels::ActiveRecordModels::NexposeConsole
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave
      serialize :cached_sites, ::MsfModels::Base64Serializer.new

      validates :name, :presence => true
      validates :address, :presence => true
      validates :username, :presence => true
      validates :password, :presence => true
      validates :port, :inclusion => {:in => 1..65535}
    }
  end
end

