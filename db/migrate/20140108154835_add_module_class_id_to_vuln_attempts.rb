# Adds vuln_attempt.module_class_id and a non-unique reference to support the {Mdm::VulnAttempt#module_class}
# association.
class AddModuleClassIdToVulnAttempts < ActiveRecord::Migration
  # Adds reference to `module_class` and an index on the `module_class_id` column from that reference.
  #
  # @return [void]
  def change
    change_table :vuln_attempts do |t|
      t.references :module_class

      t.index :module_class_id
    end
  end
end
