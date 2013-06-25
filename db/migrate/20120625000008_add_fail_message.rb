# Adds fail_detail to *_attempts tables.
class AddFailMessage < ActiveRecord::Migration
  # Removes exploit_attempts.fail_detail and vuln_attempts.fail_detail.
  #
  # @return [void]
  def down
    remove_column :vuln_attempts, :fail_detail
    remove_column :exploit_attempts, :fail_detail
  end

  # Adds exploit_attempts.fail_detail and vuln_attempts.fail_detail.
  #
  # @return [void]
  def up
    add_column :vuln_attempts, :fail_detail, :text
    add_column :exploit_attempts, :fail_detail, :text
  end
end
