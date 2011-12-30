class WebTemplate < ActiveRecord::Base
	belongs_to :campaign

	extend Msf::DBManager::SerializedPrefs

	serialize :prefs, Msf::Base64Serializer.new

	serialized_prefs_attr_accessor :exploit_type
	serialized_prefs_attr_accessor :exploit_name, :exploit_opts
end

