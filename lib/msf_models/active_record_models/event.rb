module MsfModels::ActiveRecordModels::Event
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave
      belongs_to :workspace, :class_name => "Msm::Workspace"
      belongs_to :host

      serialize :info, ::MsfModels::Base64Serializer.new

      scope :flagged, where(:critical => true, :seen => false)
      scope :module_run, where(:name => 'module_run')

      validates_presence_of :name
    }
  end
end

