module MsfModels::ActiveRecordModels::ReportTemplate
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave

      belongs_to :workspace
    }
  end
end

