module MsfModels::ActiveRecordModels::Vuln
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave
      belongs_to :host
      belongs_to :service
      has_and_belongs_to_many :refs, :join_table => :vulns_refs
    }
  end
end
