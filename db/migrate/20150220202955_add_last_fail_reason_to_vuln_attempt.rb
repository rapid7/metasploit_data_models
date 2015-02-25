class AddLastFailReasonToVulnAttempt < ActiveRecord::Migration
  def change
    add_column :vuln_attempts, :last_fail_reason, :string
  end
end
