# Tag {#host_tags assigned} to {#hosts}.  Tags can be used to group together hosts for targeting and reporting.
class Mdm::Tag < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] host_tags
  #  Joins {#hosts} to this tag.
  #
  #  @return [Array<Mdm::HostTag>]
  has_many :host_tags,
           :class_name => 'Mdm::HostTag',
           :dependent => :destroy

  # @!attribute [rw] user
  #   User that created this tag.
  #
  #   @return [Mdm::User]
  belongs_to :user, :class_name => 'Mdm::User'

  #
  # :through => :hosts_tags
  #

  # @!attribute [r] hosts
  #   Host that are tagged with this tag.
  #
  #   @return [Array<Mdm::Host>]
  has_many :hosts, :class_name => 'Mdm::Host', :through => :host_tags

  #
  # Attributes
  #

  # @!attribute [rw] created_at
  #   When this tag was created by {#user}.
  #
  #   @return [DateTime]

  # @!attribute [rw] critical
  #   Whether this tag represents a critical finding about the {#hosts}.
  #
  #   @return [true] this tag is critical.
  #   @return [false] this tag is non-critical.

  # @!attribute [rw] desc
  #   Longer description of what this tag should be used for or means when applied to a {#hosts host}.
  #
  #   @return [String]

  # @!attribute [rw] name
  #   The name of the tag.  The name is what a user actually enters to tag a {#hosts host}.
  #
  #   @return [String]

  # @!attribute [rw] report_detail
  #   Whether to include this tag in a {Mdm::Report report} details section.
  #
  #   @return [true] include this tag in the report details section.
  #   @return [false] do not include this tag in the report details section.

  # @!attribute [rw] report_summary
  #   Whether to include this tag in a {Mdm::Report report} summary section.
  #
  #   @return [true] include this tag in the report summary section.
  #   @return [false] do not include this tag in the report summary section.
  #   @todo https://www.pivotaltracker.com/story/show/52417783

  # @!attribute [rw] updated_at
  #   The last time this tag was updated.
  #
  #   @return [DateTime]

  #
  # Validations
  #

  validates :desc,
            :length => {
                :maximum => ((8 * (2 ** 10)) - 1),
                :message => "desc must be less than 8k."
            }
  validates :name,
            :format => {
                :with => /^[A-Za-z0-9\x2e\x2d_]+$/, :message => "must be alphanumeric, dots, dashes, or underscores"
            },
            :presence => true

  # Destroy this tag if it has no {#host_tags}
  #
  # @return [void]
  def destroy_if_orphaned
    self.class.transaction do
      if host_tags.empty?
        destroy
      end
    end
  end

  # (see #name)
  def to_s
    name
  end

  ActiveSupport.run_load_hooks(:mdm_tag, self)
end
