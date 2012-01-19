module MsfModels::ActiveRecordModels::EmailAddress
  def self.included(base)
    base.class_eval{
      belongs_to :campaign, :class_name => "Msm::EmailAddress"
    }
  end
end
