module MsfModels::ActiveRecordModels::Route
  def self.included(base)
    base.class_eval{
      belongs_to :session, :class_name => "Msm::Session"
    }
  end
end
