module MetasploitDataModels::ActiveRecordModels::Session
  def self.included(base)
    base.class_eval{
      belongs_to :host

      has_one :workspace, :through => :host, :class_name => "Mdm::Workspace"

      has_many :events, :class_name => "Mdm::SessionEvent", :order => "created_at"
      has_many :routes

      scope :alive, :conditions => "closed_at IS NULL"
      scope :dead, :conditions => "closed_at IS NOT NULL"

      serialize :datastore, ::MetasploitDataModels::Base64Serializer.new
    }
  end
end
