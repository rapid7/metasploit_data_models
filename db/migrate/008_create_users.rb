# Creates users.
class CreateUsers < ActiveRecord::Migration
  # Drops users.
  #
  # @return [void]
  def down
    drop_table :users
  end

  # Creates users.
  #
  # @return [void]
  def up
    create_table :users do |t|
      t.string :username
      t.string :crypted_password
      t.string :password_salt
      t.string :persistence_token

      t.timestamps
    end
  end
end
