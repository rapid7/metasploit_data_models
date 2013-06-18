# Drops vulns_refs which has been replaced by vuln_references.  Data was already migrated out in
# {TranslateRefsToReferences}.
class DropVulnsRefs < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being dropped
  TABLE_NAME = :vulns_refs

  # Recreates vulns_refs, but does not restore data.
  #
  # @return [void]
  def down
    create_table TABLE_NAME do |t|
      t.references :ref
      t.references :vuln
    end
  end

  # Drops vulns_refs
  #
  # @return [void]
  def up
    drop_table TABLE_NAME
  end
end
