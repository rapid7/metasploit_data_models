module MetasploitDataModels::ActiveRecordModels::Ref
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave
      has_and_belongs_to_many :vulns, :join_table => :vulns_refs, :class_name => "Mdm::Vuln"
    }
  end
end
