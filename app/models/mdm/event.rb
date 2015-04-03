class Mdm::Event < ActiveRecord::Base
    
  #
  # Associations
  #

  belongs_to :host,
             class_name: 'Mdm::Host',
             inverse_of: :events

  belongs_to :workspace,
             class_name: 'Mdm::Workspace',
             inverse_of: :events
  
  #
  # Scopes
  #

  scope :flagged, -> { where(:critical => true, :seen => false) }
  scope :module_run, -> { where(:name => 'module_run') }

  #
  # Serializations
  #

  serialize :info, MetasploitDataModels::Base64Serializer.new

  #
  # Mass Assignment Security
  #
  
  # Database Columns
  
  attr_accessible :name, :critical, :seen, :username, :info
  
  # Foreign Keys
  
  attr_accessible :workspace_id, :host_id
  
  # Model Associations
  
  attr_accessible :host, :workspace

  #
  # Validations
  #

  validates :name, :presence => true

  Metasploit::Concern.run(self)
end

