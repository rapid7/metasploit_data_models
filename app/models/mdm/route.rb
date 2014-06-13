class Mdm::Route < ActiveRecord::Base
  #
  # Relations
  #

  # @!attribute [rw] session
  #   The session over which this route traverses.
  #
  #   @return [Mdm::Session]
  belongs_to :session,
             class_name: 'Mdm::Session',
             inverse_of: :routes

  ActiveSupport.run_load_hooks(:mdm_route, self)
end
