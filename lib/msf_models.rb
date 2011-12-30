require "msf_models/version"
require "active_record"
require "msf_models/db_manager/db_objects"
require "msf_models/db_manager/serialized_prefs"
require "msf_models/db_manager/base64_serializer"

models_dir = File.expand_path(File.dirname(__FILE__)) + "/msf_models/active_record_models"
Dir.glob("#{models_dir}/*.rb").each do |model_file|
  require model_file
end



module MsfModels
  
end
