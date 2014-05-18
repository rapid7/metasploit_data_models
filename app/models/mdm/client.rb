class Mdm::Client < ActiveRecord::Base
  #
  # Relations
  #
  belongs_to :host,
             class_name: 'Mdm::Host',
             inverse_of: :clients

  ActiveSupport.run_load_hooks(:mdm_client, self)
end
