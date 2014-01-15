# Changes all the {COLUMNS} in the vuln_attempts table that are required for {Mdm::VulnAttempt}, but were
# previously `null: true`
class ChangedRequiredColumnsToNullFalseInVulnAttempts < MetasploitDataModels::ChangeRequiredColumnsToNullFalse
  # Columns that were previously :null => true, but are actually required to be non-null, so should be
  # `null: false`
  COLUMNS = [
      :attempted_at,
      :exploited,
      :username,
      :vuln_id
  ]
  # Table in which {COLUMNS} are.
  TABLE_NAME = :vuln_attempts
end
