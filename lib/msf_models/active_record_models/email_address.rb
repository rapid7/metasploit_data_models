module MsfModels::ActiveRecordModels::EmailAddress
  def self.included(base)
    base.class_eval{
      belongs_to :campaign
    }
  end
end
