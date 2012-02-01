module MsfModels::ActiveRecordModels::Note
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave
      notes = base.arel_table      

      belongs_to :workspace, :class_name => "Msm::Workspace"
      belongs_to :host, :class_name => "Msm::Host"
      belongs_to :service, :class_name => "Msm::Service"
      serialize :data, ::MsfModels::Base64Serializer.new

      scope :flagged, where('critical = true AND seen = false')
      scope :visible, where(notes[:ntype].not_in(['web.form', 'web.url', 'web.vuln']))


      after_save :normalize

      private

      def normalize
        if data_changed? and ntype =~ /fingerprint/
          host.normalize_os
        end
      end
    }
  end
end

