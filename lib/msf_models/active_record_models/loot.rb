module MsfModels::ActiveRecordModels::Loot
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave

      belongs_to :workspace, :class_name => "Msm::Workspace"
      belongs_to :host, :class_name => "Msm::Host"
      belongs_to :service, :class_name => "Msm::Service"

      serialize :data, ::MsfModels::Base64Serializer.new
    }
  end
end

