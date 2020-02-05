class RemoveNotNullFromWebVulnPArams < ActiveRecord::Migration[4.2]
  def change
    change_column_null(:web_vulns, :params, true)
  end
end
