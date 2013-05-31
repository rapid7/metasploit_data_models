# Change index on module_authors from detail_id to a unique index on (detail_id, name) to enforce that only one author
# of a given name should exist for a given module.  email is not unique on the off chance that two authors want to
# use the same email alias.
class UniqueNameScopedToDetailIdInModuleAuthors < ActiveRecord::Migration
  #
  # CONSTANS
  #

  # Table whose indices to change.
  TABLE_NAME = :module_authors

  # Removes unique index on (detail_id, name) and restores the index on detail_id.
  #
  # @return [void]
  def down
    change_table TABLE_NAME do |t|
      t.remove_index [:detail_id, :name]

      t.index :detail_id, :name => 'index_module_authors_on_module_detail_id'
    end
  end

  # Replaces index on detail_id with unique index on detail_id and name.
  #
  # @return [void]
  def up
    change_table TABLE_NAME do |t|
      t.remove_index :name => 'index_module_authors_on_module_detail_id'

      t.index [:detail_id, :name], :unique => true
    end
  end
end
