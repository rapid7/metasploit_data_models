# Open Sourced Vulnerability Database authority-specific code.
module Mdm::Authority::Osvdb
  # Returns URL to {Mdm::Reference#designation OSVDB ID's} page.
  #
  # @param designation [String] N+ OSVDB ID.
  # @return [String] URL
  def self.designation_url(designation)
    "http://www.osvdb.org/#{designation}/"
  end
end
