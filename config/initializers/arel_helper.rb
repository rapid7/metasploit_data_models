# Including arel-helpers in all active record models.
# https://github.com/camertron/arel-helpers

ApplicationRecord.send(:include, ArelHelpers::ArelTable)
ApplicationRecord.send(:include, ArelHelpers::JoinAssociation)
