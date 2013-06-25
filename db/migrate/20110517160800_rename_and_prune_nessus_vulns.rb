# Drops vulns where vulns.name starts with NSS-*.
class RenameAndPruneNessusVulns < ActiveRecord::Migration
  # Model to help find vulns with NSS-* vulns.name.
	class Vuln < ActiveRecord::Base
	end

  # Does nothing.
  #
  # @return [void]
	def down
		say "Cannot un-rename and un-prune NSS vulns for migration 20110517160800."
  end

	# No table changes, just vuln renaming to drop the NSS id
	# from those vulns that have it and a descriptive name.
  #
  # @return [void]
	def up
		Vuln.find(:all).each do |v|
			if v.name =~ /^NSS-0?\s*$/
				v.delete
				next
			end
			next unless(v.name =~ /^NSS-[0-9]+\s(.+)/)
			new_name = $1
			next if(new_name.nil? || new_name.strip.empty?)
			v.name = new_name
			v.save!
		end
	end
end
