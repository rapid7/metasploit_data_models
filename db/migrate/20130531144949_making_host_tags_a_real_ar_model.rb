class MakingHostTagsARealArModel < ActiveRecord::Migration[4.2]
  def change
    add_column :hosts_tags, :id, :primary_key
  end

end
