# Changes users.admin to `:null => false`.  All records with `nil` {Mdm::User#admin}, will have it set to `true` to
# match the default.
class RequireAdminFlag < ActiveRecord::Migration
  # Reverts users.admin to `:null => true`.
  #
  # @return [void]
  def down
    change_column :users, :admin, :boolean, :default => true
  end

  # Changes users.admin to `:null => false`.  All records with `nil` {Mdm::User#admin}, will have it set to `true` to
  # match the default.
  #
  # @return [void]
  def up
    # update any existing records
    Mdm::User.update_all({:admin => true}, {:admin => nil})

    change_column :users, :admin, :boolean, :null => false, :default => true
  end
end
