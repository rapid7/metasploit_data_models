module MsfModels::ActiveRecordModels::Vuln
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave
      belongs_to :host, :class_name => "Msm::Host"
      belongs_to :service, :class_name => "Msm::Service"
      has_and_belongs_to_many :refs, :join_table => :vulns_refs, :class_name => "Msm::Ref"
    }
  end
end
