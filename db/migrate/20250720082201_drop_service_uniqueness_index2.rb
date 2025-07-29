class DropServiceUniquenessIndex2 < ActiveRecord::Migration[7.0]
  def change
    remove_index(:services, :host_id_and_port_and_proto)
  end
end
