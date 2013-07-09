# 1. A ruby Class defined in one {Mdm::Module::Ancestor#real_path} for non-payloads.
# 2. A ruby Class with one or more ruby Modules mixed into the Class from {Mdm::Module::Ancestor#real_path multiple paths}
#    for payloads.
class Mdm::Module::Class < ActiveRecord::Base
  include Metasploit::Model::Derivation
  include Metasploit::Model::Derivation::FullName

  self.table_name = 'module_classes'

  #
  # CONSTANTS
  #

  # Valid values for {#payload_type} when {#payload?} is `true`.
  PAYLOAD_TYPES = [
      'single',
      'staged'
  ]

  # The {Mdm::Module::Ancestor#payload_type} when {#payload_type} is 'staged'.
  STAGED_ANCESTOR_PAYLOAD_TYPES = [
      'stage',
      'stager'
  ]

  #
  #
  # Associations
  #
  #

  # @!attribute [rw] module_instance
  #   Instance-derived metadata to go along with the class-derived metadata from this model.
  #
  #   @return [Mdm::Module::Instance]
  has_one :module_instance,
          :class_name => 'Mdm::Module::Instance',
          :dependent => :destroy,
          :foreign_key => :module_class_id

  # @!attribute [rw] rank
  #   The reliability of the module and likelyhood that the module won't knock over the service or host being exploited.
  #   Bigger values is better.
  #
  #   @return [Mdm::Module::Rank]
  belongs_to :rank, :class_name => 'Mdm::Module::Rank'

  # @!attribute [rw] relationships
  #   Join model between {Mdm::Module::Class} and {Mdm::Module::Ancestor} that represents that the Class or Module in
  #   {Mdm::Module::Ancestor#real_path} is an ancestor of the Class represented by this {Mdm::Module::Class}.
  #
  #   @return [Array<Mdm::Module::Relationship>]
  has_many :relationships,
           :class_name => 'Mdm::Module::Relationship',
           :dependent => :destroy,
           :foreign_key => :descendant_id

  #
  # :through => :relationships
  #

  # @!attribute [r] ancestors
  #   The Class or Modules that were loaded to make this module Class.
  #
  #   @return [Array<Mdm::Module::Ancestor>]
  has_many :ancestors, :class_name => 'Mdm::Module::Ancestor', :through => :relationships

  #
  # Attributes
  #

  # @!attribute [rw] full_name
  #   The full name (type + reference) for the Class<Msf::Module>.  This is merely a denormalized cache of
  #   `"#{{#module_type}}/#{{#reference_name}}"` as full_name is used in numerous queries and reports.
  #
  #   @return [String]

  # @!attribute [rw] module_type
  #   A denormalized cache of the {Mdm::Module::Class#module_type ancestors' module_types}, which must all be the
  #   same.  This cache exists so that queries for modules of a given type don't need include the {#ancestors}.
  #
  #   @return [String]

  # @!attribute [rw] payload_type
  #   For payload modules, the {PAYLOAD_TYPES type} of payload, either 'single' or 'staged'.
  #
  #   @return [String] if {#payload?} is `true`.
  #   @return [nil] if {#payload?} is `false`

  # @!attribute [rw] reference_name
  #   The reference name for the Class<Msf::Module>. For non-payloads, this will just be
  #   {Mdm::Module::Ancestor#reference_name} for the only element in {#ancestors}.  For payloads composed of a
  #   stage and stager, the reference name will be derived from the {Mdm::Module::Ancestor#reference_name} of each
  #   element {#ancestors} or an alias defined in those Modules.
  #
  #   @return [String]

  #
  # Derivations
  #

  derives :module_type, :validate => true
  derives :payload_type, :validate => true
  # reference_name depends on module_type and conditionally depends on payload_type if module_type is 'payload'
  derives :reference_name, :validate => true

  # full_name depends on module_type and reference_name
  derives :full_name, :validate => true

  #
  # Validations
  #

  validate :ancestor_count
  validate :ancestor_payload_types
  validate :ancestor_module_types

  validates :module_type,
            :inclusion => {
                :in => Mdm::Module::Ancestor::MODULE_TYPES
            }
  validates :payload_type,
            :inclusion => {
                :if => :payload?,
                :in => PAYLOAD_TYPES
            },
            :nil => {
                :unless => :payload?
            }
  validates :rank,
            :presence => true
  validates :reference_name,
            :presence => true

  #
  # Methods
  #

  # Derives {#module_type} from the consensus of {#ancestors ancestors'}
  # {Mdm::Module::Ancestor#module_type module_types}.
  #
  # @return [String] if all {#ancestors} have the same {Mdm::Module::Ancestor#module_type module_type}.
  # @return [nil] if there are no {#ancestors}.
  # @return [nil] if {#ancestors} do not have the same {Mdm::Module::Ancestor#module_type module_type}.
  def derived_module_type
    module_type_consensus = nil
    module_type_set = Set.new

    ancestors.each do |ancestor|
      module_type_set.add ancestor.module_type
    end

    if module_type_set.length == 1
      module_type_consensus = module_type_set.to_a.first
    end

    module_type_consensus
  end

  # Derives {#payload_type} based on {#ancestors ancestor's} {Mdm::Module::Ancestor#payload_type payload_type}.
  #
  # @return ['single'] if {#payload?} and single ancestor with {Mdm::Module::Ancestor#payload_type payload_tye}
  #   'single'.
  # @return ['staged'] if {#payload?} and one ancestor with {Mdm::Module::Ancestor#payload_type payload_type} 'stager'
  #   and another ancestor with {Mdm::Module::Ancestor#payload_type payload_type} 'stage'.
  # @return [nil] otherwise
  def derived_payload_type
    derived = nil

    if payload?
      case ancestors.length
        when 1
          if ancestors.first.payload_type == 'single'
            derived = 'single'
          end
        when 2
          payload_type_set = Set.new

          ancestors.each do |ancestor|
            payload_type_set.add ancestor.payload_type
          end

          if payload_type_set.include? 'stager' and payload_type_set.include? 'stage'
            derived = 'staged'
          end
      end
    end

    derived
  end

  # Derives {#reference_name} from {#ancestors}.
  #
  # @return [String] '<single_ancestor.reference_name>/<single_ancestor.handler_type>' if {#payload_type} is
  #   'single'.
  # @return [String] '<stage_ancestor.reference_name>/<stager_ancestor.handler_type>' if {#payload_type} is 'staged'.
  # @return [String] '<ancestor.reference_name>' if not {#payload?}.
  # @return [nil] otherwise
  def derived_reference_name
    derived = nil

    if payload?
      case payload_type
        when 'single'
          derived = derived_single_payload_reference_name
        when 'staged'
          derived = derived_staged_payload_reference_name
      end
    else
      if ancestors.length == 1
        derived = ancestors.first.reference_name
      end
    end

    derived
  end

  # Returns whether this represents a Class<Msf::Payload>.
  #
  # @return [true] if {#module_type} == 'payload'
  # @return [false] if {#module_type} != 'payload'
  def payload?
    if module_type == 'payload'
      true
    else
      false
    end
  end

  private

  # Validates that number of {#ancestors} is correct for the {#module_type}.
  #
  # @return [void]
  def ancestor_count
    if payload?
      case payload_type
        when 'single'
          unless ancestors.length == 1
            errors[:ancestors] << 'must have exactly one ancestor for single payload module class'
          end
        when 'staged'
          unless ancestors.length == 2
            errors[:ancestors] << 'must have exactly two ancestors (stager + stage) for staged payload module class'
          end
        # other (invalid) types are handled by validation on payload_type
      end
    else
      unless ancestors.length == 1
        errors[:ancestors] << 'must have exactly one ancestor as a non-payload module class'
      end
    end
  end

  # Validates that {#ancestors} all have the same {Mdm::Module::Ancestor#module_type} as {#module_type}.
  #
  # @return [void]
  def ancestor_module_types
    ancestor_module_type_set = Set.new

    ancestors.each do |ancestor|
      if module_type and ancestor.module_type != module_type
        errors[:ancestors] << "can contain ancestors only with same module_type (#{module_type}); " \
                              "#{ancestor.full_name} cannot be an ancestor due to its module_type " \
                              "(#{ancestor.module_type})"
      end

      ancestor_module_type_set.add ancestor.module_type
    end

    if ancestor_module_type_set.length > 1
      ancestor_module_type_sentence = ancestor_module_type_set.sort.to_sentence
      errors[:ancestors] << "can only contain ancestors with one module_type, " \
                            "but contains multiple module_types (#{ancestor_module_type_sentence})"
    end
  end

  # Validates that {#ancestors} have correct {Mdm::Module::Ancestor#payload_type payload_types} for the {#module_type}
  # and {#payload_type}.
  #
  # @return [void]
  def ancestor_payload_types
    if payload?
      case payload_type
        when 'single'
          ancestors.each do |ancestor|
            unless ancestor.payload_type == 'single'
              errors[:ancestors] << "cannot have an ancestor (#{ancestor.full_name}) " \
                                    "with payload_type (#{ancestor.payload_type}) " \
                                    "for class payload_type (#{payload_type})"
            end
          end
        when 'staged'
          ancestors_by_payload_type = ancestors.group_by(&:payload_type)

          STAGED_ANCESTOR_PAYLOAD_TYPES.each do |ancestor_payload_type|
            staged_payload_type_count(ancestors_by_payload_type, ancestor_payload_type)
          end

          ancestors_by_payload_type.each do |ancestor_payload_type, ancestors|
            unless STAGED_ANCESTOR_PAYLOAD_TYPES.include? ancestor_payload_type
              full_names = ancestors.map(&:full_name)
              full_name_sentence = full_names.to_sentence

              errors[:ancestors] << "cannot have ancestors (#{full_name_sentence}) " \
                                    "with payload_type (#{ancestor_payload_type}) " \
                                    "for class payload_type (#{payload_type}); " \
                                    "only one stage and one stager ancestor is allowed"
            end
          end
      end
    else
      ancestors.each do |ancestor|
        if ancestor.payload_type
          errors[:ancestors] << "cannot have an ancestor (#{ancestor.full_name}) " \
                                "with a payload_type (#{ancestor.payload_type}) " \
                                "for class module_type (#{module_type})"
        end
      end
    end
  end

  # @note Caller should check that {#payload?} is `true` and {#payload_type} is 'single' before calling
  #   {#derived_single_payload_reference_name}.
  #
  # Derives {#reference_name} for single payload.
  #
  # @return [String] '<single_ancestor.reference_name>/<single_ancestor.handler_type>'
  # @return [nil] unless exactly one {#ancestors ancestor}.
  # @return [nil] unless {Mdm::Module::Ancestor#payload_type} is 'single'.
  # @return [nil] if {Mdm::Module::Ancestor#reference_name} is `nil`.
  # @return [nil] if {Mdm::Module::Ancestor#handler_type} is `nil`.
  def derived_single_payload_reference_name
    derived = nil

    if ancestors.length == 1
      ancestor = ancestors.first

      if ancestor.payload_type == 'single' and ancestor.reference_name and ancestor.handler_type
        derived = "#{ancestor.reference_name}/#{ancestor.handler_type}"
      end
    end

    derived
  end

  # @note Caller should check that {#payload?} is `true` and {#payload_type} is 'staged' before calling
  #   {#derived_staged_payload_reference_name}.
  #
  # Derives {#reference_name} for staged payload.
  #
  # @return [String] '<stage_ancestor.reference_name>/<stager_ancestor.handler_type>'
  # @return [nil] unless exactly two {#ancestors ancestor}.
  # @return [nil] unless {Mdm::Module::Ancestor#payload_type} is 'single'.
  # @return [nil] if {Mdm::Module::Ancestor#reference_name} is `nil`.
  # @return [nil] if {Mdm::Module::Ancestor#handler_type} is `nil`.
  def derived_staged_payload_reference_name
    derived = nil

    if ancestors.length == 2
      ancestors_by_payload_type = ancestors.group_by(&:payload_type)
      stage_ancestors = ancestors_by_payload_type.fetch('stage', [])

      # length can be 0..2
      if stage_ancestors.length == 1
        stage_ancestor = stage_ancestors.first

        if stage_ancestor.reference_name
          stager_ancestors = ancestors_by_payload_type.fetch('stager', [])

          # length can be 0..1
          if stager_ancestors.length == 1
            stager_ancestor = stager_ancestors.first

            if stager_ancestor.handler_type
              derived = "#{stage_ancestor.reference_name}/#{stager_ancestor.handler_type}"
            end
          end
        end
      end
    end

    derived
  end

  # Validates that only 1 ancestor with the given payload_type exists.
  #
  # @param ancestors_by_payload_type [Hash{String => Array<Mdm::Module::Ancestor>}] Maps
  #   {Mdm::Module::Ancestor#payload_type} to the Array of {Mdm::Module::Ancestor} with that
  #   {Mdm::Module::Ancestor#payload_type}.
  # @param ancestor_payload_type [String] {Mdm::Module::Ancestor#payload_type}.
  # @return [void]
  def staged_payload_type_count(ancestors_by_payload_type, ancestor_payload_type)
    payload_type_ancestors = ancestors_by_payload_type.fetch(ancestor_payload_type, [])
    payload_type_ancestor_count = payload_type_ancestors.length

    if payload_type_ancestor_count < 1
      errors[:ancestors] << "needs exactly one ancestor with payload_type (#{ancestor_payload_type}), " \
                            "but there are none."
    elsif payload_type_ancestor_count > 1
      full_names = payload_type_ancestors.map(&:full_name).sort
      full_name_sentence = full_names.to_sentence
      errors[:ancestors] << "needs exactly one ancestor with payload_type (#{ancestor_payload_type}), " \
                            "but there are #{payload_type_ancestor_count} (#{full_name_sentence})"
    end
  end

  # restore public scope for load hooks
  public

  ActiveSupport.run_load_hooks(:mdm_module_class, self)
end