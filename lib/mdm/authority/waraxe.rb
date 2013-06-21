# Waraxe authority-specific code.
module Mdm::Authority::Waraxe
  #
  # CONSTANTS
  #

  # Regular expression for breaking up designation into year and number
  DESIGNATION_REGEXP = /\A(?<year>\d+)-SA#(?<number>\d+)\Z/

  #
  # Methods
  #

  # Returns URL to {Mdm::Reference#designation Waraxe Security Advisory's} page on Waraxe's site.
  #
  # @param designation [String] YYYY-SA#N+ Waraxe fully-qualified ID.
  # @return [String] URL
  # @return [nil] if designation does not match {DESIGNATION_REGEXP}.
  def self.designation_url(designation)
    match = DESIGNATION_REGEXP.match(designation)
    url = nil

    if match
      number = match[:number]

      url = "http://www.waraxe.us/advisory-#{number}.html"
    end

    url
  end
end
