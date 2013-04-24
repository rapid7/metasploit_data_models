class AddCredsCounterCache < ActiveRecord::Migration
  def up
    add_column :hosts, :cred_count, :integer, :default => 0
    Mdm::Host.reset_column_information
    # Set initial counts
    cred_service_ids = Set.new
    Mdm::Cred.all.each {|c| cred_service_ids << c.service_id}
    cred_service_ids.each do |service_id|
      #Mdm::Host.reset_counters(Mdm::Service.find(service_id).host.id, :creds)
      host = Mdm::Service.find(service_id).host
      host.cred_count = host.creds.count
      host.save
    end
  end

  def down
    remove_column :hosts, :cred_count
  end
end
