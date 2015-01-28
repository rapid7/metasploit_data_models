class Mdm::HostTag < ActiveRecord::Base
  self.table_name = "hosts_tags"

  #
  # Associations
  #

  # @!attribute host
  #   Host with {#tag}.
  #
  #   @todo MSP-2723
  #   @return [Mdm::Host]
  belongs_to :host,
             class_name: 'Mdm::Host',
             inverse_of: :hosts_tags

  # @!attribute tag
  #   Tag on {#host}.
  #
  #   @todo MSP-2723
  #   @return [Mdm::Tag]
  belongs_to :tag,
             class_name: 'Mdm::Tag',
             inverse_of: :hosts_tags

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
    tag.destroy_if_orphaned
  end

  public

  Metasploit::Concern.run(self)
end

