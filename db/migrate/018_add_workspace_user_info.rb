# Adds workspaces.boundary and real-world user info, such as users.company, users.email, users.fullname, and
# users.phone.
class AddWorkspaceUserInfo < ActiveRecord::Migration
  # Removes users.company, users.email, users.fullname, users.phone, and workspaces.boundary.
  #
  # @return [void]
  def down
    change_table :workspaces do |t|
      t.remove :boundary
    end

    change_table :users do |t|
      t.remove :fullname
      t.remove :email
      t.remove :phone
      t.remove :company
    end
  end

  # Adds users.company, users.email, users.fullname, users.phone, and workspaces.boundary.
  #
  # @return [void]
  def up
    change_table :workspaces do |t|
      t.string :boundary, :limit => 4096
    end

    change_table :users do |t|
      t.string :fullname
      t.string :email
      t.string :phone
      t.string :company
    end
  end
end

