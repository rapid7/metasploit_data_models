# including arel-helpers in all active record models. this should be moved down to mdm.
# https://github.com/camertron/arel-helpers
require 'arel-helpers'

ActiveRecord::Base.send(:include, ArelHelpers::ArelTable)
ActiveRecord::Base.send(:include, ArelHelpers::JoinAssociation)
