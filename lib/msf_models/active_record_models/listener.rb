module MsfModels::ActiveRecordModels::Listener
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave

      belongs_to :workspace
      belongs_to :task

      serialize :options, ::MsfModels::Base64Serializer.new
      validates :address, :presence => true, :ip_format => true
      validates :port, :presence => true
    }
  end
end

