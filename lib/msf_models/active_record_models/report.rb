module MsfModels::ActiveRecordModels::Report
  def self.included(base)
    base.class_eval {
      include Msf::DBManager::DBSave

      belongs_to :workspace, :class_name => "Msm::Workspace"
      serialize :options, ::MsfModels::Base64Serializer.new

      validates_format_of :name, :with => /^[A-Za-z0-9\x20\x2e\x2d\x5c]+$/, :message => "name must be A-Z, 0-9, space, dot, underscore, or dash", :allow_blank => true

      serialize :options, MsfModels::Base64Serializer.new

      before_destroy :delete_file

      scope :flagged, where('reports.downloaded_at is NULL')

      private

      def delete_file
        c = Pro::Client.get
        c.report_delete_file(self[:id])
      end
    }
  end
end

