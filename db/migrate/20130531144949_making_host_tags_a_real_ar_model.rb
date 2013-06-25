# Adds hosts_tags.id.
class MakingHostTagsARealArModel < ActiveRecord::Migration
  # Adds hosts_tags.id.
  #
  # @return [void]
  def change
    add_column :hosts_tags, :id, :primary_key
  end
end
