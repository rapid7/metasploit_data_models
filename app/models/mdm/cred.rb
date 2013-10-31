# A credential captured from a {#service}.
class Mdm::Cred < ActiveRecord::Base
  #
  # CONSTANTS
  #

  # Checks if {#proof} is an SSH Key in {#ssh_key_id}.
  SSH_KEY_ID_REGEXP = /(?<ssh_key_id>[0-9a-fA-F:]{47})/

  # Maps {#ptype} to human {#ptype}.
  HUMAN_PTYPE_BY_PTYPE = {
      'password_ro' => 'read-only password',
      'password_rw' => 'read/write password',
      'smb_hash' => 'SMB hash',
      'ssh_key' => 'SSH private key',
      'ssh_pubkey' => 'SSH public key'
  }

  # {#ptype Password types} for SSH Private and Public keys.
  SSH_PTYPES = [
      'ssh_key',
      'ssh_pubkey'
  ]

  #
  #
  # Associations
  #
  #

  # @!attribute [rw] service
  #   The service this cred is for
  #
  #   @return [Mdm::Service]
  belongs_to :service, class_name: 'Mdm::Service', inverse_of: :creds

  # @!attribute [rw] task_creds
  #   Details about what Tasks touched this cred
  #
  #   @return [Array<Mdm::TaskCred>]
  has_many :task_creds, class_name: 'Mdm::TaskCred', dependent: :destroy, inverse_of: :cred

  #
  # :through => :service
  #

  # @!attribute [r] host
  #   Host on which {#service} is running.
  #
  #   @return [Mdm::Host]
  has_one :host, :class_name => 'Mdm::Host', :through => :service

  #
  # :through => :host
  #

  # @!attribute [r] workspace
  #   Workspace in which {#host} was discovered.
  #
  #   @return [Mdm::Workspace]
  has_one :workspace, :class_name => 'Mdm::Workspace', :through => :host

  #
  # :through => :task_creds
  #

  # @!attribute [rw] tasks
  #   Tasks that touched this service
  #
  #   @return [Array<Mdm::Task>]
  has_many :tasks, :class_name => 'Mdm::Task', :through => :task_creds

  #
  # :through => :workspace
  #

  # @!attribute [r] workspace_hosts
  #   Hosts in {#workspace}.
  #
  #   @return [Array<Mdm::Host>]
  has_many :workspace_hosts, :class_name => 'Mdm::Host', :source => :hosts, :through => :workspace

  #
  # :through => :workspace_hosts
  #

  # @!attribute [r] workspace_services
  #   Services running on {#workspace_hosts}.
  #
  #   @return [Array<Mdm::Service>]
  has_many :workspace_services, :class_name => 'Mdm::Service', :source => :services, :through => :workspace_hosts

  #
  # :through => :workspace_services
  #

  # @!attribute [r] workspace_creds
  #   Creds for {#workspace_services}.
  #
  #   @return [Array<Mdm::Cred>]
  has_many :workspace_creds, :class_name => 'Mdm::Cred', :source => :creds, :through => :workspace_services

  #
  # Attributes
  #

  # @!attribute [rw] active
  #   Whether the credential is active.
  #
  #   @return [false] if a captured credential cannot be used to log into {#service}.
  #   @return [true] otherwise

  # @!attribute [rw] created_at
  #   When this credential was created.
  #
  #   @return [DateTime]

  # @!attribute [rw] pass
  #   Pass of credential.
  #
  #   @return [String, nil]

  # @!attribute [rw] proof
  #   Proof of credential capture.
  #
  #   @return [String]

  # @!attribute [rw] ptype
  #   Type of {#pass}.
  #
  #   @return [String]

  # @!attribute [rw] source_id
  #   Id of source of this credential.
  #
  #   @return [Integer, nil]

  # @!attribute [rw] source_type
  #   Type of source with {#source_id}.
  #
  #   @return [String, nil]

  # @!attribute [rw] updated_at
  #   The last time this credential was updated.
  #
  #   @return [DateTime]

  # @!attribute [rw] user
  #   User name of credential.
  #
  #   @return [String, nil]

  #
  # Callbacks
  #

  after_create :increment_host_counter_cache
  after_destroy :decrement_host_counter_cache

  #
  # Scopes
  #

  #
  # @!group Scopes
  #

  # @!method self.none
  #   Returns no records
  #
  #   @todo Remove when only Rails 4 is supported as it defines none scope for all classes.
  #   @return [ActiveRecord::Relation] relation with no matching records no matter which scopes are chained.
  scope :none,
        lambda {
          where(
              Arel::SqlLiteral.new('1 = 0')
          )
        }

  # @!method self.ssh_key_id(ssh_key_id)
  #   All {Mdm::Cred creds} whose {#proof} matches `ssh_key_id`.
  #
  #   @return [ActiveRecord::Relation] creds with same {#ssh_key_id} unless `ssh_key_id` is `nil`.
  #   @return [ActiveRecord::Relation] no creds if `ssh_key_id` is `nil`.
  scope :ssh_key_id,
        lambda { |ssh_key_id|
          if ssh_key_id
            formatted_ssh_key_id = "%#{ssh_key_id}%"

            where(
                arel_table[:proof].matches(formatted_ssh_key_id)
            )
          else
            none
          end
        }

  # @!method self.ssh_keys
  #   All {Mdm::Cred creds} where {#ptype} is `'ssh_key'` or `'ssh_pubkey'`.
  #
  #   @return [ActiveRecord::Relation]
  scope :ssh_keys,
        lambda {
          where(
              arel_table[:ptype].eq_any(SSH_PTYPES)
          )
        }

  # @!method self.ssh_private_keys
  #   All {Mdm::Cred creds} where {#ptype} is `'ssh_key'`.
  #
  #   @return [ActiveRecord::Relation]
  scope :ssh_private_keys,
        lambda {
          where(:ptype => 'ssh_key')
        }

  # @!method self.ssh_public_keys
  #   All {Mdm::Cred creds} where {#ptype} is `'ssh_pubkey'`.
  #
  #   @return [ActiveRecord::Relation]
  scope :ssh_public_keys,
        lambda {
          where(:ptype => 'ssh_pubkey')
        }

  #
  # @!endgroup
  #

  #
  # Methods
  #

  # Humanized {#ptype}.
  #
  # @return [String, nil]
  def ptype_human
    HUMAN_PTYPE_BY_PTYPE.fetch(ptype, ptype)
  end

  # Returns SSH Key ID.
  #
  # @return [String] SSH Key Id if ssh-type key and {#proof} matches {SSH_KEY_ID_REGEXP}.
  # @return [nil] otherwise
  def ssh_key_id
    ssh_key_id = nil

    if SSH_PTYPES.include? ptype
      match = SSH_KEY_ID_REGEXP.match(proof)

      if match
        ssh_key_id = match[:ssh_key_id].downcase
      end
    end

    ssh_key_id
  end

  # Returns whether `other`'s SSH private key or public key matches.
  #
  # @return [false] if `other` is not same class as `self`.
  # @return [false] if {#ptype} does not match.
  # @return [false] if {#ptype} is not in {SSH_PTYPES}.
  # @return [false] if {#ssh_key_id} is `nil`.
  # @return [false] if {#ssh_key_id} does not match.
  # @return [true] if {#ssh_key_id} matches.
  def ssh_key_matches?(other)
    matches = false

    if other.is_a?(self.class) and
        other.ptype == self.ptype and
        SSH_PTYPES.include?(ptype) and
        ssh_key_id and
        other.ssh_key_id == self.ssh_key_id
      matches = true
    end

    matches
  end

  # Returns all keys with matching key ids, including itself.
  #
  # @return [ActiveRecord::Relation] ssh_key and ssh_pubkey creds with matching {#ssh_key_id}.
  def ssh_keys
    workspace_creds.ssh_keys.ssh_key_id(ssh_key_id)
  end

  # Returns all private keys with matching {#ssh_key_id}, including itself.
  #
  # @return [ActiveRecord::Relation] ssh_key creds with matching {#ssh_key_id}.
  def ssh_private_keys
    workspace_creds.ssh_private_keys.ssh_key_id(ssh_key_id)
  end

  # Returns all public keys with matching {#ssh_key_id}, including itself.
  #
  # @return [ActiveRecord::Relation] ssh_pubkey creds with matching {#ssh_key_id}.
  def ssh_public_keys
    workspace_creds.ssh_public_keys.ssh_key_id(ssh_key_id)
  end

  private

  # Decrements {Mdm::Host#cred_count}.
  #
  # @return [void]
  def decrement_host_counter_cache
    Mdm::Host.decrement_counter("cred_count", self.service.host_id)
  end

  # Increments {Mdm::Host#cred_count}.
  #
  # @return [void]
  def increment_host_counter_cache
    Mdm::Host.increment_counter("cred_count", self.service.host_id)
  end

  # Switch back to public for load hooks.
  public

  ActiveSupport.run_load_hooks(:mdm_cred, self)
end
