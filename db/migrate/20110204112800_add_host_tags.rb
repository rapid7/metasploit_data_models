# Creates hosts_tags and tags.
class AddHostTags < ActiveRecord::Migration
  # Drops hosts_tags and tags.
  #
  # @return [void]
  def down
    drop_table :hosts_tags
    drop_table :tags
  end

  # Creates hosts_tags and tags.
  #
  # @return [void]
  def up
    create_table :tags do |t|
      t.integer  :user_id
      t.string   :name, :limit => 1024
      t.text     :desc
      t.boolean  :report_summary, :null => false, :default => false
      t.boolean  :report_detail, :null => false, :default => false
      t.boolean  :critical, :null => false, :default => false
      t.timestamps
    end

    create_table :hosts_tags, :id => false do |t|
      t.integer :host_id
      t.integer :tag_id
    end
  end
end

