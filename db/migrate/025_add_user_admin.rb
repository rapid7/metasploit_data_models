# Add user admin flag and project member list.
class AddUserAdmin < ActiveRecord::Migration
  # Removes users.admin and drops project_memebers.
  #
  # @return [void]
  def down
    remove_column :users, :admin

    drop_table :project_members
  end

  # Add user admin flag and project member list.
  #
  # @return [void]
  def up
    add_column :users, :admin, :boolean, :default => true

    create_table :project_members, :id => false do |t|
      t.integer :workspace_id, :null => false
      t.integer :user_id, :null => false
    end
  end
end

