module MetasploitDataModels::ActiveRecordModels::Campaign
  def self.included(base)
    base.class_eval{
      has_one :email_template, :dependent => :delete, :class_name => "Mdm::EmailTemplate"
      has_one :web_template, :dependent => :delete, :class_name => "Mdm::WebTemplate"
      has_one :attachment, :dependent => :delete, :class_name => "Mdm::Attachment"
      has_many :email_addresses, :dependent => :delete_all, :class_name => "Mdm::EmailAddress"
      has_many :clients, :dependent => :delete_all, :class_name => "Mdm::Client"

      extend ::MetasploitDataModels::SerializedPrefs

      serialize :prefs, ::MetasploitDataModels::Base64Serializer.new
    
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

      validates_presence_of :name
      # Don't use validates_uniqueness_of because it does a 'SELECT id ...'
      # instead of 'SELECT *' so when we get the object in after_initialize, it
      # only has an id attribute and trying to save it will raise
      # ActiveRecord::MissingAttributeError.
      # see https://rails.lighthouseapp.com/workspaces/8994/tickets/3165-activerecordmissingattributeerror-after-update-to-rails-v-234
      #validates_uniqueness_of :name, :scope => :workspace_id

      validates :web_uripath, :format => {:with => /^\//, :message => "must start with '/'"}

      validates :payload_lhost, :listener_lhost,
                :format => {:with => /^(:?\d+\.){3}\d+/, :message => "must be an IP address"}

      validates_inclusion_of :smtp_port, :web_srvport, :exe_lport,
                             :in => 1..65535, :message => "must be a number between 1 and 65535"
    }
  end
end
