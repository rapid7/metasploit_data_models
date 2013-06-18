# Join model between {Mdm::Vuln} and {Mdm::Reference}.
class Mdm::VulnReference < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] reference
  #   {Mdm::Reference Reference} to {#vuln} from an external {Mdm::Authority authority}.
  #
  #   @return [Mdm::Reference]
  belongs_to :reference, :class_name => 'Mdm::Reference'

  # @!attribute [rw] vuln
  #   {Mdm::Vuln Vulnerability} imported or discovered by metasploit.
  #
  #   @return [Mdm::Vuln]
  belongs_to :vuln, :class_name => 'Mdm::Vuln'

  #
  # Validations
  #

  validates :reference, :presence => true
  validates :reference_id,
            :uniqueness => {
                :scope => :vuln_id
            }
  validates :vuln, :presence => true
end