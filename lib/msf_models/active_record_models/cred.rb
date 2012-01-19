module MsfModels::ActiveRecordModels::Cred
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave
      belongs_to :service, :class_name => "Msm::Service"

      def ssh_key_matches?(other)
        return false unless other.kind_of? self.class
        return false unless self.ptype == "ssh_key"
        return false unless self.ptype == other.ptype
        return false unless other.proof
        return false if other.proof.empty?
        return false unless self.proof
        return false if self.proof.empty?
        key_id_regex = /[0-9a-fA-F:]+/
          my_key_id = self.proof[key_id_regex].to_s.downcase 
        other_key_id = other.proof[key_id_regex].to_s.downcase
        my_key_id == other_key_id
      end
    }
  end
end
