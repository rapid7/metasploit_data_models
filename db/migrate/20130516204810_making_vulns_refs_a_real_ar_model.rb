class MakingVulnsRefsARealArModel < ActiveRecord::Migration[4.2]
  def change
    add_column :vulns_refs, :id, :primary_key
  end
end
