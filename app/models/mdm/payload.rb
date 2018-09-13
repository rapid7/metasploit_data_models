class Mdm::Payload < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Model::Search

  #
  # Associations
  #

  # {Mdm::Workspace} in which this payload was created.  If {#host} is present, then this will match
  # {Mdm::Host#workspace `host.workspace`}.
  belongs_to :workspace,
             class_name: 'Mdm::Workspace',
             inverse_of: :payloads

  #
  # Search Attributes
  #

  search_attribute :uuid,
                   type: :string

  #
  # Serializations
  #

  serialize :urls

end
