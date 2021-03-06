class MakeMatchPolymorphic < ActiveRecord::Migration[4.2]
  def up
    add_column :automatic_exploitation_matches, :matchable_type, :string
    add_column :automatic_exploitation_matches, :matchable_id, :integer
  end

  def down
    remove_column :automatic_exploitation_matches, :matchable_type
    remove_column :automatic_exploitation_matches, :matchable_id
  end
end
