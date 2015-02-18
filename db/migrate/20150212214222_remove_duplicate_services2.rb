class RemoveDuplicateServices2 < ActiveRecord::Migration
  def change
    duplicate_keys = Mdm::Service.count(group: [:host_id, :port, :proto]).select { |k,v| v >1 }.keys
    duplicate_keys.each do |keys|
      duplicate_services = Mdm::Service.where(host_id: keys[0], port: keys[1], proto: keys[2]).order(:created_at)
      duplicate_services.pop
      duplicate_services.each(&:destroy)
    end

    add_index :services, [:host_id, :port, :proto], unique: true
  end
end
