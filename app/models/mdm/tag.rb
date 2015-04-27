class Mdm::Tag < ActiveRecord::Base
  include Metasploit::Model::Search

  #
  # Associations
  #

  # @!attribute hosts_tags
  #  Joins {#hosts} to this tag.
  #
  #  @return [ActiveRecord::Relation<Mdm::HostTag>]
  has_many :hosts_tags,
           class_name: 'Mdm::HostTag',
           dependent: :destroy,
           inverse_of: :tag

  belongs_to :user,
             class_name: 'Mdm::User',
             inverse_of: :tags

  #
  # Through :hosts_tags
  #

  # @!attribute [r] hosts
  #   Host that are tagged with this tag.
  #
  #   @return [ActiveRecord::Relation<Mdm::Host>]
  has_many :hosts, :through => :hosts_tags, :class_name => 'Mdm::Host'

  #
  # Search
  #

  search_attribute :desc,
                   type: :string
  search_attribute :name,
                   type: :string

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
                :with => /\A[A-Za-z0-9\x2e\x2d_]+\z/, :message => "must be alphanumeric, dots, dashes, or underscores"
            },
            :presence => true

  #
  # Instance Methods
  #

  # Destroy this tag if it has no {#hosts_tags}
  #
  # @return [void]
  def destroy_if_orphaned
    self.class.transaction do
      if hosts_tags.empty?
        destroy
      end
    end
  end

  def to_s
    name
  end

  Metasploit::Concern.run(self)
end
