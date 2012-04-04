module MetasploitDataModels::ActiveRecordModels::Client
  def self.included(base)
    base.class_eval {
      include Msf::DBManager::DBSave
      belongs_to :host, :class_name => "Mdm::Host"
      belongs_to :campaign, :class_name => "Campaign"
    }
  end
end
