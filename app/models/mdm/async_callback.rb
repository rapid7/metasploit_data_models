# An asychronous callback that has been received by the Mettle Pingback Listener and is logged
class Mdm::AsyncCallback < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Model::Search

  #
  # Associations
  #

  # @!attribute [rw] workspace
  # {Mdm::Workspace} in which this payload was created.
  #
  #   @return [Mdm::Workspace]
  belongs_to :workspace,
             class_name: 'Mdm::Workspace',
             inverse_of: :payloads


  #
  # Attributes
  #

  # @!attribute [rw] uuid
  #   A 16-byte unique identifier for this payload. The UUID is encoded to include specific information.
  #   See lib/msf/core/payload/uuid.rb in the https://github.com/rapid7/metasploit-framework repo.
  #
  #   @return [String]

  # @!attribute [rw] timestamp
  #   The Unix format timestamp when this payload called back.
  #
  #   @return [Integer]

  # @!attribute [rw] listener_uri
  #   Non-unique URIs (eg. "tcp://192.168.1.7:4444") which received callbacks from this payload.
  #
  #   @return [String]

  # @!attribute [rw] target_host
  #   The IP address (eg. "192.168.1.7" or "fe80::1") from which the callback originated, from the view of the callback listener.
  #
  #   @return [String]

  # @!attribute [rw] target_port
  #   The IP port (eg. "4444") from which the callback originated, from the view of the callback listener.
  #
  #   @return [Integer]

  # @!attribute [rw] workspace_id
  #   The ID of the workspace this payload belongs to.
  #
  #   @return [Integer]

  #
  # Validations
  #

  validates :workspace, :presence => true


  #
  # Search Attributes
  #

  search_attribute :uuid,
                   type: :string

  #
  # Serializations
  #

  # NONE


  public

  Metasploit::Concern.run(self)
end
