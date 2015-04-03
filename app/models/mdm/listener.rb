class Mdm::Listener < ActiveRecord::Base
  
  #
  # Associations
  #

  belongs_to :task,
             class_name: 'Mdm::Task',
             inverse_of: :listeners

  belongs_to :workspace,
             class_name: 'Mdm::Workspace',
             inverse_of: :listeners

  #
  # Serializations
  #

  serialize :options, MetasploitDataModels::Base64Serializer.new

  #
  # Mass Assignment Security
  #
  
  # Database Columns
  
  attr_accessible :enabled, :owner, :payload, :address, :port, :options, :macro
  
  # Foreign Keys
  
  attr_accessible :workspace_id, :task_id
  
  # Model Associations
  
  attr_accessible :task, :workspace
  
  #
  # Validations
  #

  validates :address, :ip_format => true, :presence => true
  validates :port, :presence => true, :numericality => { :only_integer => true }, :inclusion => {:in => 1..65535}

  Metasploit::Concern.run(self)
end

