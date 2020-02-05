class AddFingerprintedToWorkspace < ActiveRecord::Migration[4.2]
  def change
    add_column :workspaces, :import_fingerprint, :boolean, default: false
  end
end
