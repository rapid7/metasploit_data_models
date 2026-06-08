# Creates the `module_execution_errors` table — one row per unhandled exception
# or explicit failure raised within a {Mdm::ModuleExecution}
class CreateModuleExecutionErrors < ActiveRecord::Migration[7.0]
  def change
    create_table :module_execution_errors do |t|
      t.references :module_execution,
                   null: false,
                   foreign_key: { on_delete: :cascade },
                   index: false
      t.text :exception_class
      t.text :message
      t.text :backtrace
      t.text :lifecycle_phase, null: false
      t.text :failure_reason
      t.column :occurred_at, :timestamptz, null: false
      t.column :created_at,  :timestamptz, null: false
      t.column :updated_at,  :timestamptz, null: false
    end

    add_index :module_execution_errors,
              [:module_execution_id, :occurred_at],
              name: 'idx_module_execution_errors_on_execution_and_occurred_at'

    add_check_constraint :module_execution_errors,
                         "lifecycle_phase IN ('setup','check','exploit','cleanup','post','run')",
                         name: 'module_execution_errors_lifecycle_phase_check'
  end
end
