# Changes string hosts.arch to hosts.architecture_id foreign key pointing to architectures.id
class ChangeHostsArchToArchitectureId < ActiveRecord::Migration
  # Recreates hosts.arch; translates architectures.abbreviation to hosts.arch; then removes hosts.architecture_id.
  #
  # @return [void]
  def down
    change_table :hosts do |t|
      t.string :arch, :null => true
    end

    execute "UPDATE hosts " \
            "SET arch = architectures.abbreviation " \
            "FROM architectures " \
            "WHERE architectures.id = hosts.architecture_id"

    change_table :hosts do |t|
      t.remove_references :architecture
    end
  end

  # Creates hosts.architecture_id; translates hosts.arch to architectures.abbreviation; then removes hosts.arch.
  #
  # @return [void]
  def up
    change_table :hosts do |t|
      t.references :architecture, :null => true
    end

    execute "UPDATE hosts " \
            "SET architecture_id = architectures.id " \
            "FROM architectures " \
            "WHERE architectures.abbreviation = hosts.arch"

    change_table :hosts do |t|
      t.remove :arch

      # create index now that the column in filled.
      t.index :architecture_id
    end
  end
end
