# Adds a {match match class method} to the extending class.  The extending class must define `MATCH_REGEXP`.
#
# @example Define `match` class method
#   class MetasploitDataModels::Search::Operation::IPAddress::Format < Metasploit::Model::Search::Operation::Base
#     extend MetasploitDataModels::Search::Operation::IPAddress::Match
#
#     #
#     # CONSTANTS
#     #
#
#     # Regular expression {MetasploitDataModels::Search::Operation::IPAddress::Match#match} must match against.
#     MATCH_REGEXP = /.../
#   end
#
#   instance = MetapsloitDataModels::Search::Operation::IPAddress::Format.match('123')
module MetasploitDataModels::Search::Operation::IPAddress::Match
  # Creates a new instance of the extending class if `MATCH_REGEXP`, defined on the extending class, matches
  # `formatted_value`.
  #
  # @param formatted_value [#to_s]
  def match(formatted_value)
    instance = nil

    if self::MATCH_REGEXP.match(formatted_value)
      instance = new(value: formatted_value)
    end

    instance
  end
end