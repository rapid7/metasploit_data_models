# Translates refs and vulns_refs to authorities, references, and vuln_references.
class TranslateRefsToReferences < ActiveRecord::Migration
  # Does nothing
  #
  # @return [void]
  def down
  end

  # Translates refs and vulns_refs to authorities, references, and vuln_references.
  #
  # @void
  def up
    # Maps refs.id to references.id
    reference_id_by_ref_id = {}

    refs = exec_query "SELECT refs.id, refs.name FROM refs"

    refs.each do |row|
      refs_id = row['id'].to_i
      refs_name = row['name']

      authorities_abbreviation, references_designation = refs_name.split('-', 2)

      if authorities_abbreviation == 'URL'
        reference = Mdm::Reference.where(
            :url => references_designation
        ).first_or_create!
      else
        authorities = Mdm::Authority.arel_table
        authority = Mdm::Authority.where(
            authorities[:abbreviation].matches(authorities_abbreviation)
        ).first_or_create!(
            # first_or_create! cannot infer value from matches AREL.
            :abbreviation => authorities_abbreviation
        )

        reference = Mdm::Reference.where(
            :authority_id => authority.id,
            :designation => references_designation
        ).first_or_create!
      end

      reference_id_by_ref_id[refs_id] = reference.id
    end

    vulns_refs = exec_query "SELECT vulns_refs.ref_id, vulns_refs.vuln_id FROM vulns_refs"

    vulns_refs.each do |row|
      ref_id = row['ref_id'].to_i
      vuln_id = row['vuln_id'].to_i

      reference_id = reference_id_by_ref_id[ref_id]

      Mdm::VulnReference.where(
          :reference_id => reference_id,
          :vuln_id => vuln_id
      ).first_or_create!
    end
  end
end
