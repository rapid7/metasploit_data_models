# Common Vulnerabilities and Exposures authority-specific code.
module Mdm::Authority::Cve
  # Returns URL to {Mdm::Reference#designation the CVE ID's} page on CVE Details.
  #
  # @param designation [String] YYYY-NNNN CVE ID.
  # @return [String] URL
  def self.designation_url(designation)
    "http://cvedetails.com/cve/CVE-#{designation}"
  end
end
