# Replaces sessions.platforms with sessions.architecture_id and sessions.platform_id.
class ReplacePlatformWithArchitectureIdAndPlatformIdInSessions < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  TABLE_NAME = :sessions

  #
  # Methods
  #

  # @raise ActiveRecord::IrreversibleMigration Migration cannot be reversed because records made after this migration
  #   may have an architecture_id and that architecture will not be reflected in all of the old-style platforms, such
  #   as those for shell sessions.
  def down
    raise ActiveRecord::IrreversibleMigration
  end

  # Converts session.platform string column to a sessions.architecture_id, which references architectures.id and
  # sessions.platform_id which references platforms.id.  Both foreign keys are indexed.
  #
  # @return [void]
  def up
    change_table TABLE_NAME do |t|
      # legacy session rows may not get an architecture or platform.
      t.references :architecture, null: true
      t.references :platform, null: true

      t.index :architecture_id
      t.index :platform_id
    end

    execute "UPDATE sessions " \
            "SET platform_id = platforms.id " \
            "FROM platforms " \
            "WHERE (platforms.fully_qualified_name = 'UNIX' AND " \
                   "sessions.platform = 'unix') OR " \
                  "(platforms.fully_qualified_name = 'Windows' AND " \
                   "sessions.platform = 'windows')"

    execute "UPDATE sessions " \
            "SET architecture_id = architectures.id, " \
                "platform_id = platforms.id " \
            "FROM architectures, " \
                 "platforms " \
            "WHERE (sessions.platform = 'java/java' AND " \
                   "architectures.abbreviation = 'java' AND " \
                   "platforms.fully_qualified_name = 'Java') OR " \
                  "(sessions.platform = 'php/php' AND " \
                   "architectures.abbreviation = 'php' AND " \
                   "platforms.fully_qualified_name = 'PHP') OR " \
                  "(sessions.platform = 'python/python' AND " \
                   "architectures.abbreviation = 'python' AND " \
                   "platforms.fully_qualified_name = 'Python') OR " \
                  "(sessions.platform = 'x64/win64' AND " \
                   "architectures.abbreviation = 'x86_64' AND " \
                   "platforms.fully_qualified_name = 'Windows') OR " \
                  "(sessions.platform = 'x86/bsd' AND " \
                   "architectures.abbreviation = 'x86' AND " \
                   "platforms.fully_qualified_name = 'BSD') OR " \
                  "(sessions.platform = 'x86/linux' AND " \
                   "architectures.abbreviation = 'x86' AND " \
                   "platforms.fully_qualified_name = 'Linux') OR " \
                  "(sessions.platform = 'x86/win32' AND " \
                   "architectures.abbreviation = 'x86' AND " \
                   "platforms.fully_qualified_name = 'Windows')"

    change_table TABLE_NAME do |t|
      t.remove :platform
    end
  end
end
