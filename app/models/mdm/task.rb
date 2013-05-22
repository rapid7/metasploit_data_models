class Mdm::Task < ActiveRecord::Base
  #
  # Callbacks
  #

  before_destroy :delete_file

  #
  # Relations
  #

  # @!attribute [rw] workspace
  #   The Workspace the Task belongs to
  #
  #   @return [Mdm::Workspace]
  belongs_to :workspace, :class_name => "Mdm::Workspace"

  # @!attribute [rw] task_creds
  #   Details about creds this task touched
  #
  #   @return [Array<Mdm::TaskCred>]
  has_many :task_creds, :class_name => 'Mdm::TaskCred'

  # @!attribute [rw] creds
  #   Creds this task touched
  #
  #   @return [Array<Mdm::TaskCred>]
  has_many :creds, :through => :task_creds, :class_name => 'Mdm::Cred'

  # @!attribute [rw] task_hosts
  #   Details about hosts this task touched
  #
  #   @return [Array<Mdm::TaskHost>]
  has_many :task_hosts, :class_name => 'Mdm::TaskHost'

  # @!attribute [rw] hosts
  #   Hosts this task touched
  #
  #   @return [Array<Mdm::TaskHost>
  has_many :hosts, :through => :task_hosts, :class_name => 'Mdm::Host'

  # @!attribute [rw] task_services
  #   Details about services this task touched
  #
  #   @return [Array<Mdm::TaskService>]
  has_many :task_services, :class_name => 'Mdm::TaskService'

  # @!attribute [rw] services
  #   Services this task touched
  #
  #   @return [Array<Mdm::TaskHost>
  has_many :services, :through => :task_services, :class_name => 'Mdm::Service'

  #
  # Scopes
  #

  scope :running, order( "created_at DESC" ).where("completed_at IS NULL")

  #
  # Serializations
  #

  serialize :options, MetasploitDataModels::Base64Serializer.new
  serialize :result, MetasploitDataModels::Base64Serializer.new
  serialize :settings, MetasploitDataModels::Base64Serializer.new

  private

  def delete_file
    c = Pro::Client.get rescue nil
    if c
      c.task_delete_log(self[:id]) if c
    else
      ::File.unlink(self.path) rescue nil
    end
  end

  ActiveSupport.run_load_hooks(:mdm_task, self)
end

