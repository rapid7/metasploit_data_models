# Creates the `module_execution_events` table — optional generalized timeline
# entries attached to a {Mdm::ModuleExecution}.
class CreateModuleExecutionEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :module_execution_events do |t|
      t.references :module_execution,
                   null: false,
                   foreign_key: { on_delete: :cascade },
                   index: false
      t.text :name, null: false
      t.jsonb :payload
      t.column :occurred_at, :timestamptz, null: false
      t.column :created_at,  :timestamptz, null: false
    end

    add_index :module_execution_events,
              [:module_execution_id, :occurred_at],
              name: 'idx_module_execution_events_on_execution_and_occurred_at'

    add_index :module_execution_events,
              [:name, :occurred_at],
              name: 'idx_module_execution_events_on_name_and_occurred_at'
  end
end
