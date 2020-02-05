class AddVulnIdToNote < ActiveRecord::Migration[4.2]
  def change
    add_column :notes, :vuln_id, :integer
    add_index :notes, :vuln_id
  end
end
