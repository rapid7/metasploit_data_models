# Join model between {Mdm::Service} and {Mdm::Service} for many-to-many self-referencing relationship
class Mdm::ServiceLink < ApplicationRecord
  self.table_name = 'service_links'

  #
  # Associations
  #

  # Parent service
  belongs_to :parent,
             class_name: 'Mdm::Service',
             inverse_of: :child_links

  # Child service
  belongs_to :child,
             class_name: 'Mdm::Service',
             inverse_of: :parent_links

  # Destroy orphaned child when destroying a service link
  after_destroy :destroy_orphan_child

  #
  # Attributes
  #

  # @!attribute created_at
  #   When this task service was created.
  #
  #   @return [DateTime]

  # @!attribute updated_at
  #   The last time this task service was updated.
  #
  #   @return [DateTime]

  #
  # Validations
  #

  validates :parent_id,
            :uniqueness => {
                :scope => :child_id
            }

  def destroy_orphan_child
    Mdm::Service.where(id: child.id).first&.destroy_if_orphaned
  end
  private :destroy_orphan_child

  Metasploit::Concern.run(self)
end

