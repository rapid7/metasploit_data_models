module MsfModels::ActiveRecordModels::ReportTemplate
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave

      belongs_to :workspace, :class_name => "Msm::Workspace"

      before_destroy :delete_file

      private

      def delete_file
        c = Pro::Client.get
        c.report_template_delete_file(self[:id])
      end
    }
  end
end

