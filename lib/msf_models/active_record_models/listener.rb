module MsfModels::ActiveRecordModels::Listener
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave

      belongs_to :workspace, :class_name => "Msm::Workspace"
      belongs_to :task, :class_name => "Msm::Task"

      serialize :options, ::MsfModels::Base64Serializer.new
      validates :address, :presence => true, :ip_format => true
      validates :port, :presence => true
    }
  end
end

