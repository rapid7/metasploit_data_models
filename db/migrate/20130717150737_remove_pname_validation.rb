# Allows `web_vulns.pname` to be `:null => true` as not all WebVulns deal with parameters.
class RemovePnameValidation < ActiveRecord::Migration
  # Changes `web_vulns.pname` from `:null => true` to `:null => false`
  #
  # @return [void]
  def change
		change_column :web_vulns, :pname, :text, :null => true
  end
end
