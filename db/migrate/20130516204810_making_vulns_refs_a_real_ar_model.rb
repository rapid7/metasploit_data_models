# Adds vulns_refs.id
class MakingVulnsRefsARealArModel < ActiveRecord::Migration
  # Adds vulns_refs.id
  #
  # @return [void]
  def change
    add_column :vulns_refs, :id, :primary_key
  end
end