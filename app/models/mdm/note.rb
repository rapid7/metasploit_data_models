# Data gathered or derived from the {#host} or {#service} such as its {#ntype fingerprint}.
class Mdm::Note < ApplicationRecord

  #
  # Associations
  #

  # @!attribute [rw] host
  #   The host to which this note is attached.
  #
  #   @return [Mdm::Host] if note is attached to an {Mdm::Host}.
  #   @return [nil] if note is attached to an {Mdm::Service}.
  belongs_to :host,
             class_name: 'Mdm::Host',
             counter_cache: :note_count,
             optional: true,
             inverse_of: :notes

  # @!attribute [rw] service
  #   The service to which this note is attached.
  #
  #   @return [Mdm::Service] if note is attached to an {Mdm::Service}.
  #   @return [nil] if not is attached to an {Mdm::Host}.
  belongs_to :service,
             class_name: 'Mdm::Service',
             optional: true,
             inverse_of: :notes

  # @!attribute [rw] vuln
  #   The vuln to which this note is attached.
  #
  #   @return [Mdm::Vuln] if note is attached to an {Mdm::Vuln}.
  #   @return [nil] if not is attached to an {Mdm::Host}.
  belongs_to :vuln,
             class_name: 'Mdm::Vuln',
             optional: true,
             inverse_of: :notes

  # @!attribute [rw] workspace
  #   The workspace in which the {#host} or {#service} exists.
  #
  #   @return [Mdm::Workspace]
  belongs_to :workspace,
             class_name: 'Mdm::Workspace',
             inverse_of: :notes

  #
  # Attributes
  #

  # @!attribute [rw] created_at
  #   When the note was created.
  #
  #   @return [DateTime]

  # @!attribute [rw] critical
  #   Whether this note is critical or not.
  #
  #   @return [Boolean]

  # @!attribute [rw] data
  #   A Hash of data about the {#host} or {#service}.
  #
  #   @return [Hash]

  # @!attribute [rw] ntype
  #   The type of note.  Usually a dot-separateed name like 'host.updated.<foo>'.
  #
  #   @return [String]

  # @!attribute [rw] seen
  #   Whether any user has seen this note.
  #
  #   @return [Boolean]

  # @!attribute [rw] updated_at
  #   The last time the note was updated.
  #
  #   @return [DateTime]

  #
  # Callbacks
  #

  after_save :normalize

  #
  # Scopes
  #

  scope :flagged, -> { where('critical = true AND seen = false') }

  scope :visible, -> { where(Mdm::Note[:ntype].not_in(['web.form', 'web.url', 'web.vuln'])) }

  scope :search, lambda { |*args|
    joins(:host).
      where(
        "(notes.data NOT ILIKE 'BAh7%' AND notes.data LIKE ?) " +
          "OR (notes.data ILIKE 'BAh7%' AND decode(notes.data, 'base64') LIKE ?) " +
          'OR notes.ntype ILIKE ? ' +
          'OR COALESCE(hosts.name, CAST(hosts.address AS TEXT)) ILIKE ?',
        "%#{args[0]}%", "%#{args[0]}%", "%#{args[0]}%", "%#{args[0]}%"
      )
  }

  #
  # Serializations
  #

  if ActiveRecord::VERSION::MAJOR >= 7 && ActiveRecord::VERSION::MINOR >= 1
    serialize :data, coder: ::MetasploitDataModels::Base64Serializer.new
  else
    serialize :data, ::MetasploitDataModels::Base64Serializer.new
  end

  private

  # {Mdm::Host::OperatingSystemNormalization#normalize_os Normalizes the host operating system} if the note is a
  # {#ntype fingerprint}.
  #
  # @return [void]
  def normalize
    if saved_change_to_data? and ntype =~ /fingerprint/ && host.workspace.present? && !host.workspace.import_fingerprint
      host.normalize_os
    end
  end

  public

  Metasploit::Concern.run(self)
end

