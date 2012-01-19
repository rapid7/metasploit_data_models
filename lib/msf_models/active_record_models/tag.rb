module MsfModels::ActiveRecordModels::Tag
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave
      has_and_belongs_to_many :hosts, :join_table => :hosts_tags, :class_name => "Msm::Hosts"

      def to_s
        name
      end
    }
  end
end
