# Replaces simple, named platforms, with nested set platforms that accurately reflect platform hierarchy from
# metasploit-framework.
class NestedSetPlatforms < ActiveRecord::Migration
  # Restores named platforms.
  #
  # @return [void]
  def down
    # drop nested set platforms
    drop_table :platforms

    # restore simple named platforms
    create_table :platforms do |t|
      t.text :name, null: false
    end

    change_table :platforms do |t|
      t.index :name, unique: true
    end
  end

  # Removes named platforms and replaces them with nested set platforms that can represent platform hiearchy used by
  # metasploit-framework.
  def up
    # drop named platforms
    drop_table :platforms

    # create nested platforms
    create_table :platforms do |t|
      # platform specific columns
      t.text :fully_qualified_name, null: false
      t.text :relative_name, null: false

      # nested set columns
      t.references :parent, null: true
      t.integer :right, null: false
      t.integer :left, null: false
    end

    change_table :platforms do |t|
      t.index :fully_qualified_name, unique: true
      t.index [:parent_id, :relative_name], unique: true
    end
  end
end
