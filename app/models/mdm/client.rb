class Mdm::Client < ActiveRecord::Base
  #
  # Relations
  #
  belongs_to :host, :class_name => 'Mdm::Host'

  ActiveSupport.run_load_hooks(:mdm_client, self)
end
