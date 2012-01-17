module MsfModels::ActiveRecordModels::Campaign
  def self.included(base)
    base.class_eval{
      has_one :email_template, :dependent => :delete
      has_one :web_template, :dependent => :delete
      has_one :attachment, :dependent => :delete
      has_many :email_addresses, :dependent => :delete_all
      has_many :clients, :dependent => :delete_all

      extend ::MsfModels::SerializedPrefs

      serialize :prefs, ::MsfModels::Base64Serializer.new
    
      scope :with_emails_by_id, lambda{ |the_id|
        where(:id => the_id).includes(:email_addresses)
      }

      # General settings
      serialized_prefs_attr_accessor :payload_lhost, :listener_lhost, :payload_type

      # Email settings
      serialized_prefs_attr_accessor :do_email # bool
      serialized_prefs_attr_accessor :smtp_server, :smtp_port, :smtp_ssl
      serialized_prefs_attr_accessor :smtp_user, :smtp_pass
      serialized_prefs_attr_accessor :mailfrom, :display_from

      # Web settings
      serialized_prefs_attr_accessor :do_web # bool
      serialized_prefs_attr_accessor :web_uripath, :web_urihost, :web_srvport, :web_srvhost
      serialized_prefs_attr_accessor :web_ssl # bool

      # Executable settings
      serialized_prefs_attr_accessor :do_exe_gen # bool
      serialized_prefs_attr_accessor :exe_lport
      serialized_prefs_attr_accessor :exe_name
      serialized_prefs_attr_accessor :macro_name

      # State
      serialized_prefs_attr_accessor :error
    }
  end
end
