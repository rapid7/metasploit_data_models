class AddCheckCodeToVulnAttempts < ActiveRecord::Migration[7.0]
  def change
    add_column :vuln_attempts, :check_code, :string
    add_column :vuln_attempts, :check_detail, :text
  end
end
