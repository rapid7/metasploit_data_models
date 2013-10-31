# A listener spawned by a {#task} that is waiting for connection on {#address}:{#port}.
class Mdm::Listener < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] task
  #   Task that spawned this listener.
  #
  #   @return [Mdm::Task]
  belongs_to :task, class_name: 'Mdm::Task', inverse_of: :listeners

  # @!attribute [rw] workspace
  #   Workspace which controls this listener.
  #
  #   @return [Mdm::Workspace]
  belongs_to :workspace, class_name: 'Mdm::Workspace', inverse_of: :listeners

  #
  # Attributes
  #

  # @!attribute [rw] address
  #   The IP address to which the listener is bound.
  #
  #   @return [String]

  # @!attribute [rw] created_at
  #   When this listener was created.  Not necessarily when it started listening.
  #
  #   @return [DateTime]

  # @!attribute [rw] enabled
  #   Whether listener is listening on {#address}:{#port}.
  #
  #   @return [true] listener is listening.
  #   @return [false] listener is not listening.

  # @!attribute [rw] macro
  #   {Mdm::Macro#name Name of macro} run when a connect is made to the listener.
  #
  #   @return [String]
  #   @todo https://www.pivotaltracker.com/story/show/52401927

  # @!attribute [rw] owner
  #   The name of the user that setup this listener.
  #
  #   @return [String]
  #   @see Mdm::User#username
  #   @todo https://www.pivotaltracker.com/story/show/52401069

  # @!attribute [rw] payload
  #   Reference name of the payload module that is sent when a connection is made to the listener.
  #
  #   @return [String]
  #   @todo https://www.pivotaltracker.com/story/show/52400791

  # @!attribute [rw] port
  #   Port on {#address} that listener is listening.
  #
  #   @return [Integer]

  # @!attribute [rw] updated_at
  #   The last time this listener was updated.
  #
  #   @return [DateTime]

  #
  # Serializations
  #

  # @!attribute [rw] options
  #   Options used to spawn this listener.
  #
  #   @return [Hash]
  serialize :options, MetasploitDataModels::Base64Serializer.new

  #
  # Validations
  #

  validates :address, :ip_format => true, :presence => true
  validates :port, :presence => true, :numericality => { :only_integer => true }, :inclusion => {:in => 1..65535}


  ActiveSupport.run_load_hooks(:mdm_listener, self)
end

