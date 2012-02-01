module MetasploitDataModels::ActiveRecordModels::User
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave
      extend MetasploitDataModels::SerializedPrefs
      serialize :prefs, ::MetasploitDataModels::Base64Serializer.new

      serialized_prefs_attr_accessor :nexpose_host, :nexpose_port, :nexpose_user, :nexpose_pass, :nexpose_creds_type, :nexpose_creds_user, :nexpose_creds_pass
      serialized_prefs_attr_accessor :http_proxy_host, :http_proxy_port, :http_proxy_user, :http_proxy_pass
      serialized_prefs_attr_accessor :time_zone, :session_key
      serialized_prefs_attr_accessor :last_login_address  # specifically NOT last_login_ip to prevent confusion with AuthLogic magic columns (which dont work for serialized fields)
    }
  end
end

