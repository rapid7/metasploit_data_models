module MetasploitDataModels::ActiveRecordModels::Vuln
  def self.included(base)
    base.class_eval {
      belongs_to :host, :class_name => "Mdm::Host"
      belongs_to :service, :class_name => "Mdm::Service", :foreign_key => :service_id
      has_and_belongs_to_many :refs, :join_table => :vulns_refs, :class_name => "Mdm::Ref"

      validates :name, :presence => true
      validates_associated :refs

      after_update :save_refs

      scope :search, lambda { |*args|
        where(["(vulns.name ILIKE ? or vulns.info ILIKE ?)",
          "%#{args[0]}%", "%#{args[0]}%"
        ])
      }

      private

      def save_refs
        refs.each { |ref| ref.save(:validate => false) }
      end
    }
  end
end
