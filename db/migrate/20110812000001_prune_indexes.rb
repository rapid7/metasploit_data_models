# Removes indices on hosts.comments, services.info, and vulns.info.
class PruneIndexes < ActiveRecord::Migration
  # Adds indices on hosts.comment, services.info and vulns.info.
  #
  # @return [void]
  def down
    add_index :hosts, :comments
    add_index :services, :info
    add_index :vulns, :info
  end

  # Removes indices on hosts.comments, services.info, and vulns.info.
  #
  # @return [void]
  def up
    if indexes(:hosts).map{|x| x.columns }.flatten.include?("comments")
      remove_index :hosts, :comments
    end

    if indexes(:services).map{|x| x.columns }.flatten.include?("info")
      remove_index :services, :info
    end

    if indexes(:vulns).map{|x| x.columns }.flatten.include?("info")
      remove_index :vulns, :info
    end
  end
end

