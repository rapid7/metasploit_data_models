module MetasploitDataModels::ActiveRecordModels::Tag
  def self.included(base)
    base.class_eval {
      has_many :hosts_tags, :class_name => "Mdm::HostTag"
      has_many :hosts, :through => :hosts_tags, :class_name => "Mdm::Host"

      belongs_to :user, :class_name => "Mdm::User"

      validates :name, :presence => true, :format => {
          :with => /^[A-Za-z0-9\x2e\x2d_]+$/, :message => "must be alphanumeric, dots, dashes, or underscores"
      }
      validates :desc, :length => {:maximum => 8191, :message => "desc must be less than 8k."}

      before_destroy :cleanup_hosts

      def to_s
        name
      end

      def cleanup_hosts
        # Clean up association table records
        Mdm::HostTag.delete_all("tag_id = #{self.id}")
      end
      
    }
  end
end
