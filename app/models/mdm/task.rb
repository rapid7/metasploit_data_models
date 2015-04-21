class Mdm::Task < ActiveRecord::Base
  #
  # Callbacks
  #

  before_destroy :delete_file

  #
  # Relations
  #

  # @!attribute listeners
  #   Listeners spawned by this task
  #
  #   @return [ActiveRecord::Relation<Mdm::Listener>]
  has_many :listeners,
           class_name: 'Mdm::Listener',
           dependent: :destroy,
           inverse_of: :task

  # @!attribute [rw] task_creds
  #   Joins this to {#creds}.
  #
  #   @return [ActiveRecord::Relation<Mdm::TaskCred>]
  has_many :task_creds,
           class_name: 'Mdm::TaskCred',
           dependent: :destroy,
           inverse_of: :task

  # @!attribute task_hosts
  #   Joins this to {#hosts}.
  #
  #   @return [ActiveRecord::Relation<Mdm::TaskHost>]
  has_many :task_hosts,
           class_name: 'Mdm::TaskHost',
           dependent: :destroy,
           inverse_of: :task

  # @!attribute task_services
  #   Joins this to {#services}.
  #
  #   @return [ActiveRecord::Relation<Mdm::TaskService>]
  has_many :task_services,
           class_name: 'Mdm::TaskService',
           dependent: :destroy,
           inverse_of: :task

  # @!attribute task_sessions
  #   Joins this to {#sessions}.
  #
  #   @return [ActiveRecord::Relation<Mdm::TaskSession>]
  has_many :task_sessions,
           class_name: 'Mdm::TaskSession',
           dependent: :destroy,
           inverse_of: :task

  # @!attribute [rw] workspace
  #   The Workspace the Task belongs to
  #
  #   @return [Mdm::Workspace]
  belongs_to :workspace,
             class_name: 'Mdm::Workspace',
             inverse_of: :tasks

  #
  # through: :task_creds
  #

  # @!attribute [rw] creds
  #   Creds this task touched
  #
  #   @return [Array<Mdm::Cred>]
  has_many :creds, :through => :task_creds, :class_name => 'Mdm::Cred'

  #
  # through: :task_hosts
  #

  # @!attribute [rw] hosts
  #   Hosts this task touched
  #
  #   @return [Array<Mdm::Host>
  has_many :hosts, :through => :task_hosts, :class_name => 'Mdm::Host'

  #
  # through: :task_services
  #

  # @!attribute [rw] services
  #   Services this task touched
  #
  #   @return [Array<Mdm::Service>
  has_many :services, :through => :task_services, :class_name => 'Mdm::Service'

  #
  # through: :task_sessions
  #

  # @!attribute [rw] sessions
  #   Session this task touched
  #
  #   @return [Array<Mdm::Session>
  has_many :sessions, :through => :task_sessions, :class_name => 'Mdm::Session'
  

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

  public

  Metasploit::Concern.run(self)
end

