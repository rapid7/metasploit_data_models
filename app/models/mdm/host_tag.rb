# Join model between {Mdm::Host} and {Mdm::Tag}.
class Mdm::HostTag < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] host
  #   Host with {#tag}.
  #
  #   @return [Mdm::Host]
  belongs_to :host, :class_name => 'Mdm::Host'

  # @!attribute [rw] tag
  #   Tag on {#host}.
  #
  #   @return [Mdm::Tag]
  belongs_to :tag, :class_name => 'Mdm::Tag'

  #
  # Callbacks
  #

  # @see http://stackoverflow.com/a/11694704
  after_destroy :destroy_orphan_tag

  #
  # Validations
  #

  validates :host,
            :presence => true
  validates :tag,
            :presence => true
  validates :tag_id,
            :uniqueness => {
                :scope => :host_id
            }

  private

  # Destroys {#tag} if it is orphaned
  #
  # @see http://stackoverflow.com/a/11694704
  # @return [void]
  def destroy_orphan_tag
    tag.destroy_if_orphaned
  end

  # switch back to public for load hooks
  public

  ActiveSupport.run_load_hooks(:mdm_host_tag, self)
end

