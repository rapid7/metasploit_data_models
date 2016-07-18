class RenameMdmCreds < ActiveRecord::Migration
  def up
    rename_table :creds, :creds_depricated
  end
  def down
    rename_table :creds_depricated, :creds
  end
end