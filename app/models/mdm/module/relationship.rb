# Associates an {Mdm::Module::Ancestor} with an {Mdm::Module::Class}. Shows that the ruby Class represented by
# {Mdm::Module::Class} is descended from one of more {Mdm::Module::Ancestor Mdm::Module::Ancestors}.
class Mdm::Module::Relationship < ActiveRecord::Base
  self.table_name = 'module_relationships'

  #
  # Associations
  #

  # @!attribute [rw] ancestor
  #   The {Mdm::Module::Ancestor} whose {Mdm::Module::Ancestor#real_path file} defined the ruby Class or ruby Module.
  #
  #   @return [Mdm::Module::Ancestor]
  belongs_to :ancestor, :class_name => 'Mdm::Module::Ancestor'

  # @!attribute [rw] descendant
  #   The {Mdm::Module::Class} that either has the Module in {#ancestor} mixed in or is the Class in {#ancestor}.
  #
  #   @return [Mdm::Module::Class]
  belongs_to :descendant, :class_name => 'Mdm::Module::Class'

  #
  # Validations
  #

  validates :ancestor,
            :presence => true
  validates :ancestor_id,
            :uniqueness => {
                :scope => :descendant_id
            }
  validates :descendant,
            :presence => true

  ActiveSupport.run_load_hooks(:mdm_module_relationship, self)
end