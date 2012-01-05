class WebTemplate < ActiveRecord::Base
	belongs_to :campaign
	extend MsfModels::SerializedPrefs
	serialize :prefs, MsfModels::Base64Serializer.new

	serialized_prefs_attr_accessor :exploit_type
	serialized_prefs_attr_accessor :exploit_name, :exploit_opts
end

