# Replaces module_archs table which only has a foreign key (module_archs.detail_id) to the obsolete module_details table
# with a join model table (module_architectures) with foreign keys (module_architectures.architecture_id and
# module_architectures.module_instance_id) to link the architectures and module_instances tables.
class ReplaceModuleArchsWithModuleArchitectures < ActiveRecord::Migration
  # Drops module_architectures and recreates module_archs.
  #
  # @return [void]
  def down
    drop_table :module_architectures

    create_table :module_archs do |t|
      t.text :name, :null => false

      t.references :detail, :null => false
    end

    change_table :module_archs do |t|
      t.index [:detail_id, :name], :unique => true
    end
  end

  # Drops module_archs and creates module_architectures.
  #
  # @return [void]
  def up
    drop_table :module_archs

    create_table :module_architectures do |t|
      t.references :architecture, :null => false
      t.references :module_instance, :null => false
    end

    change_table :module_architectures do |t|
      t.index [:module_instance_id, :architecture_id],
              # auto-generated name index_module_architectures_on_module_instance_and_architecture_id exceeds 63
              # character postgres limit, so supply a more compact name.
              :name => :index_unique_module_architectures,
              :unique => true
    end
  end
end
