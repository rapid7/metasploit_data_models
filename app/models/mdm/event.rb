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
  # Validations
  #

  validates :name, :presence => true

  Metasploit::Concern.run(self)
end

