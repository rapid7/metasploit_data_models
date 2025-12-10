class RemoveDuplicateServices3 < ActiveRecord::Migration[7.0]
  def change
    select_mgr = Mdm::Service.arel_table.project(
      Mdm::Service[:host_id],
      Mdm::Service[:proto],
      Mdm::Service[:port].count
    ).group(
      'host_id',
      'port',
      'proto'
    ).having(Mdm::Service[:port].count.gt(1))

    Mdm::Service.find_by_sql(select_mgr).each(&:destroy)

    add_index :services, [:host_id, :port, :proto, :name, :resource], unique: true, name: 'index_services_on_5_columns'
  end
end
