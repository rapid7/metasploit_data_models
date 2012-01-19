module MsfModels::ActiveRecordModels::Note
  def self.include(base)
    base.class_eval{
      include Msf::DBManager::DBSave

      belongs_to :workspace, :class_name => "Msm::Workspace"
      belongs_to :host, :class_name => "Msm::Host"
      belongs_to :service, :class_name => "Msm::Service"
      serialize :data, ::MsfModels::Base64Serializer.new

      def after_save
        if data_changed? and ntype =~ /fingerprint/
          host.normalize_os
        end
      end
    }
  end
end

