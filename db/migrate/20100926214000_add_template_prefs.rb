# Removes email_templates.generate_exe and add prefs to email_templates and web_templates.
class AddTemplatePrefs < ActiveRecord::Migration
  # Removes emails_templates.prefs and web_templates.prefs and restores email_templates.generate_exe.
  #
  # @return [void]
  def down
    remove_column :email_templates, :prefs
    remove_column :web_templates, :prefs

    add_column :email_templates, :generate_exe, :boolean, :null => false, :default => false
  end

  # Removes email_templats.generate_exe and adds email_templates.prefs and web_templates.prefs.
  #
  # @return [void]
	def up
		remove_column :email_templates, :generate_exe

		add_column :email_templates, :prefs, :text
		add_column :web_templates, :prefs, :text
	end
end
