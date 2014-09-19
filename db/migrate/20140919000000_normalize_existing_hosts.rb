class NormalizeExistingHosts < ActiveRecord::Migration
  def up
    Mdm::Host.find_each do |host|
      host.normalize_os
      host.save
    end
  end
end
