module MsfModels::ActiveRecordModels::Client
  def self.included(base)
    base.class_eval {
      include Msf::DBManager::DBSave
      belongs_to :host, :class_name => "Msm::Host"
      belongs_to :campaign, :class_name => "Msm::Campaign"
    }
  end
end
