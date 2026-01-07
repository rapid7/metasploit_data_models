# Join model between {Mdm::Host} and {Mdm::Tag}.
class Mdm::SessionTag < ApplicationRecord
  self.table_name = "sessions_tags"

  #
  # Associations
  #

  # Session with {#tag}.
  #
  # @todo MSP-2723
  belongs_to :session,
             class_name: 'Mdm::Session',
             inverse_of: :sessions_tags

  # Tag on {#host}.
  #
  # @todo MSP-2723
  belongs_to :tag,
             class_name: 'Mdm::Tag',
             inverse_of: :sessions_tags

  #
  # Callbacks
  #

  # @see http://stackoverflow.com/a/11694704
  after_destroy :destroy_orphan_tag
  
  #
  # Instance Methods
  #

  private

  # Destroys {#tag} if it is orphaned
  #
  # @see http://stackoverflow.com/a/11694704
  # @return [void]
  def destroy_orphan_tag
    # ensure fresh load of tag record
    # in theory this will always return one result safe navigation is just "extra"
    Mdm::Tag.where(id: tag.id).first&.destroy_if_orphaned
  end

  # switch back to public for load hooks
  public

  Metasploit::Concern.run(self)
end

