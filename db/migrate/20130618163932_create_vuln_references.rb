# Create vuln_references
class CreateVulnReferences < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being created
  TABLE_NAME = :vuln_references

  #
  # Methods
  #

  # Drops vuln_references
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Creates vuln_references
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.references :reference, :null => false
      t.references :vuln, :null => false
    end

    change_table TABLE_NAME do |t|
      t.index [:vuln_id, :reference_id], :unique => true
    end
  end
end
