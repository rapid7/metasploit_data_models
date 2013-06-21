# A user of metasploit-framework or metasploit-pro.
class Mdm::User < ActiveRecord::Base
  extend MetasploitDataModels::SerializedPrefs

  #
  # Associations
  #

  # @!attribute [rw] owned_workspaces
  #   {Mdm::Workspace Workspaces} owned by this user.  Owned workspaces allow user complete permissions without the need
  #   for the user to be an {#admin administrator}.
  has_many :owned_workspaces, :class_name => 'Mdm::Workspace', :foreign_key => 'owner_id'

  # @!attribute [rw] tags
  #   Tags created by the user.
  #
  #   @return [Array<Mdm::Tag>]
  has_many :tags, :class_name => 'Mdm::Tag'

  # @!attribute [rw] workspaces
  #   {Mdm::Workspace Workspace} where this user has access.  If a user is an {#admin administrator} they have access
  #   to all workspaces even if they are not a member of that workspace.
  #
  #   @return [Array<Mdm::Workspace>]
  has_and_belongs_to_many :workspaces,
                          :class_name => 'Mdm::Workspace',
                          :join_table => 'workspace_members',
                          :uniq => true

  #
  # :through => :tags
  #

  # @!attribute [r] host_tags
  #   Joins {#tags} to {#tagged_hosts}.
  #
  #   @return [Array<mdm::HostTag>]
  has_many :host_tags, :class_name => 'Mdm::HostTag', :through => :tags

  #
  # :through => :host_tags

  # @!attribute [r] tagged_hosts
  #   Hosts this user has tagged or that have had tags created by this user applied to the host.
  #
  #   @return [Array<Mdm::Host>]
  has_many :tagged_hosts, :class_name => 'Mdm::Host', :through => :host_tags

  #
  # Attributes
  #

  # @!attribute [rw] admin
  #   Whether this user is an administrator.  Administrator permissions are only enforced in metasploit-pro through the
  #   controllers.
  #
  #   @return [false] if this is a normal user that must be added to each workspace.
  #   @return [true] if this user is an administrator and have access to all workspaces without being added to the
  #     workspace explicitly.  User is also allowed to add other users to workspaces or make other users admins.

  # @!attribute [rw] company
  #   Company at which user works.
  #
  #   @return [String, nil]

  # @!attribute [rw] created_at
  #   When the user was created.
  #
  #   @return [DateTime]

  # @!attribute [rw] crypted_password
  #   Hashed password (salted with {#password_salt}) by Authlogic in metasploit-pro.
  #
  #   @return [String]
  #   @todo https://www.pivotaltracker.com/story/show/52129127

  # @!attribute [rw] email
  #   The user's email address.
  #
  #   @return [String, nil]

  # @!attribute [rw] fullname
  #   The user's normal human name.
  #
  #   @return [String, nil]

  # @!attribute [rw] password_salt
  #   Salt used when hashing password into {#crypted_password} by Authlogic in metasploit-pro.
  #
  #   @return [String]
  #   @todo https://www.pivotaltracker.com/story/show/52129127

  # @!attribute [rw] persistence_token
  #   Token used for session and cookie when user is logged using Authlogic in metasploit-pro.
  #
  #   @return [String]
  #   @todo https://www.pivotaltracker.com/story/show/52129127

  # @!attribute [rw] phone
  #   Phone number for user.
  #
  #   @return [String, nil]

  # @!attribute [rw] updated_at
  #   When the user was last updated.
  #
  #   @return [DateTime]

  # @!attribute [rw] username
  #   Username for this user.  Used to log into metasploit-pro.
  #
  #   @return [String]

  #
  # Serialziations
  #

  # @!attribute [rw] prefs
  #   Hash of user preferences
  #
  #   @return [Hash]
  serialize :prefs, MetasploitDataModels::Base64Serializer.new

  # @!attribute [rw] time_zone
  #   User's perferred time zone.
  #
  #   @return [String, nil]
  serialized_prefs_attr_accessor :time_zone

  #
  #  @!group Duplicate Login Monitoring
  #

  # @!attribute [rw] last_login_address
  #   @note specifically NOT last_login_ip to prevent confusion with AuthLogic magic columns (which dont work for
  #     serialized fields)
  #
  #   Last IP address from which this user logged in.  Used to report currently active user session's IP when the user
  #   is logged off because theire `session[:session_id]` does not match {#session_key}.
  #
  #   @return [String, nil]
  serialized_prefs_attr_accessor :last_login_address

  # @!attribute [rw] session_key
  #   Holds `session[:session_id]` so user can only be logged in once.  Only enforced in metasploit-pro.
  #
  #   @return [String, nil]
  serialized_prefs_attr_accessor :session_key

  #
  # @!endgroup
  #

  #
  # @!group HTTP Proxy
  #

  # @!attribute [rw] http_proxy_host
  #   Proxy host.
  #
  #   @return [String, nil]
  serialized_prefs_attr_accessor :http_proxy_host

  # @!attribute [rw] http_proxy_pass
  #   Password used to login as {#http_proxy_user} to proxy.
  #
  #   @return [String, nil]
  serialized_prefs_attr_accessor :http_proxy_pass

  # @!attribute [rw] http_proxy_port
  #   Port on which proxy run on {#http_proxy_host}.
  #
  #   @return [String, Integer, nil]
  serialized_prefs_attr_accessor :http_proxy_port

  # @!attribute [rw] http_proxy_user
  #   User used to log into proxy.
  #
  #   @return [String, nil]
  serialized_prefs_attr_accessor :http_proxy_user

  #
  # @!endgroup
  #

  #
  # @!group Nexpose
  #

  # @!attribute [rw] nexpose_host
  #   Host name for server running Nexpose.
  #
  #   @return [String, nil]
  serialized_prefs_attr_accessor :nexpose_host

  # @!attribute [rw] nexpose_pass
  #   Password to log into Nexpose.
  #
  #   @return [String, nil]
  serialized_prefs_attr_accessor :nexpose_pass

  # @!attribute [rw] nexpose_port
  #   Port on {#nexpose_host} on which Nexpose is running.
  #
  #   @return [String, Integer. nil]
  serialized_prefs_attr_accessor :nexpose_port

  # @!attribute [rw] nexpose_user
  #   User used to log into Nexpose.
  #
  #   @return [String, nil]
  serialized_prefs_attr_accessor :nexpose_user

  #
  # @!endgroup
  #

  #
  # @!group Nexpose Authenticated Scan Credentials
  #

  # @!attribute [rw] nexpose_creds_pass
  #   @return [String, nil]
  #   @todo https://www.pivotaltracker.com/story/show/52129301
  serialized_prefs_attr_accessor :nexpose_creds_pass

  # @!attribute [rw] nexpose_creds_type
  #   @return [String, nil]
  #   @todo https://www.pivotaltracker.com/story/show/52129301
  serialized_prefs_attr_accessor :nexpose_creds_type

  # @!attribute [rw] nexpose_creds_user
  #   @return [String, nil]
  #   @todo https://www.pivotaltracker.com/story/show/52129301
  serialized_prefs_attr_accessor :nexpose_creds_user

  #
  # @!endgroup
  #

  ActiveSupport.run_load_hooks(:mdm_user, self)
end

