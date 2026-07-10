# Creates the `module_executions` table. Every module invocation (or
# direct-write pseudo-execution) ultimately writes one row here.
class CreateModuleExecutions < ActiveRecord::Migration[7.0]
  def change
    create_table :module_executions do |t|
      t.references :workspace,
                   null: false,
                   foreign_key: true,
                   index: true
      t.text :module_reference_name, null: false
      t.text :module_type,           null: false
      t.text :kind,                  null: false, default: 'run'
      t.jsonb :options_snapshot
      t.text :originating_interface, null: false
      t.references :originating_user,
                   foreign_key: { to_table: :users },
                   index: true
      t.text :originating_token_ref
      t.references :parent_execution,
                   foreign_key: { to_table: :module_executions },
                   index: false
      t.column :started_at, :timestamptz, null: false
      t.column :ended_at,   :timestamptz
      t.text :terminal_status
      t.text :failure_reason
      t.text :failure_message
      t.integer :single_entity_failure_count, null: false, default: 0
      t.jsonb :last_single_entity_errors

      t.column :created_at, :timestamptz, null: false
      t.column :updated_at, :timestamptz, null: false
    end

    add_index :module_executions,
              [:workspace_id, :started_at],
              order: { started_at: :desc },
              name: 'idx_module_executions_on_workspace_and_started_at'

    add_index :module_executions,
              [:module_reference_name, :started_at],
              order: { started_at: :desc },
              name: 'idx_module_executions_on_reference_name_and_started_at'

    add_index :module_executions,
              :parent_execution_id,
              where: 'parent_execution_id IS NOT NULL',
              name: 'idx_module_executions_on_parent_execution_id_not_null'

    add_index :module_executions,
              [:kind, :originating_interface],
              name: 'idx_module_executions_on_kind_and_originating_interface'

    # Enumerated values are also validated at the AR layer; the DB
    # CHECK constraints provide a fail-loud safety net for non-AR
    # writers (raw SQL, future maintenance scripts).
    add_check_constraint :module_executions,
                         "module_type IN ('exploit','auxiliary','post','payload'," \
                         "'encoder','evasion','nop','external')",
                         name: 'module_executions_module_type_check'

    add_check_constraint :module_executions,
                         "kind IN ('run','check','import','direct_write')",
                         name: 'module_executions_kind_check'

    add_check_constraint :module_executions,
                         "originating_interface IN ('console','rpc','json_rpc','mcp'," \
                         "'external','import','plugin','autocheck')",
                         name: 'module_executions_originating_interface_check'

    add_check_constraint :module_executions,
                         "terminal_status IS NULL OR terminal_status IN " \
                         "('running','success','neutral','expected_failure','unhandled_exception')",
                         name: 'module_executions_terminal_status_check'

    # (ended_at IS NULL) <=> (terminal_status is NULL or 'running')
    add_check_constraint :module_executions,
                         "(ended_at IS NULL AND (terminal_status IS NULL OR terminal_status = 'running')) " \
                         "OR (ended_at IS NOT NULL AND terminal_status IS NOT NULL AND terminal_status <> 'running')",
                         name: 'module_executions_terminal_status_lifecycle_check'

    add_check_constraint :module_executions,
                         'ended_at IS NULL OR ended_at >= started_at',
                         name: 'module_executions_ended_at_after_started_at_check'
  end
end
