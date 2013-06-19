# Changes module_authors from referencing module_details (through detail_id) to being a 3-way join table between
# authors, email_addresses, and module_instances.
class RepurposeModuleAuthors < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being repurposed.
  TABLE_NAME = :module_authors

  # Recreate module_authors tied to module_details.
  #
  # @return [void]
  def down
    drop_table TABLE_NAME

    create_table TABLE_NAME do |t|
      #
      # Columns
      #

      t.text :name, :null => false
      t.text :email


      #
      # Foreign Keys
      #

      t.references :detail, :null => false
    end

    change_table TABLE_NAME do |t|
      t.index [:detail_id, :name], :unique => true
    end
  end

  # Drops old module_details referencing module_authors and make module_authors a 3-way join between authors,
  # email_addresses, and module_instances.
  #
  # @return [void]
  def up
    drop_table TABLE_NAME

    create_table TABLE_NAME do |t|
      t.references :author, :null => false
      t.references :email_address, :null => true
      t.references :module_instance, :null => false
    end

    change_table TABLE_NAME do |t|
      #
      # Foreign Key indices
      #

      t.index :author_id
      t.index :email_address_id
      t.index :module_instance_id

      #
      # Unique indices
      #

      t.index [:module_instance_id, :author_id], :unique => true
    end
  end
end
