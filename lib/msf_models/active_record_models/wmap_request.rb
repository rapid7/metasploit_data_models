# WMAP Request object definition
class WmapRequest < ::ActiveRecord::Base
  include Msf::DBManager::DBSave
  # Magic.
end
