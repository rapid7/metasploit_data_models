# Adds hosts.cred_count as counter cache for {Mdm::Host#creds}.
class AddCredsCounterCache < ActiveRecord::Migration
  # Removes hosts.cred_count
  #
  # @return [voi]
  def down
    remove_column :hosts, :cred_count
  end

  # Adds hosts.cred_count and populates it with count of {Mdm::Host#creds} as {Mdm::Host#creds} is an indirect
  # association through {Mdm::Host#services} and indirect associations can't support automatic counter caches.
  #
  # @return [void]
  def up
    add_column :hosts, :cred_count, :integer, :default => 0

    Mdm::Host.reset_column_information
    # Set initial counts
    cred_service_ids = Set.new
    Mdm::Cred.all.each {|c| cred_service_ids << c.service_id}
    cred_service_ids.each do |service_id|
      begin
        host = Mdm::Service.find(service_id).host
      rescue
        next
      end

      next if host.nil? # This can happen with orphan creds/services

      host.cred_count = host.creds.count
      host.save
    end
  end
end
