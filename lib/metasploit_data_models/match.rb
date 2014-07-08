# Adds a {match match class method} to the extending class.  The extending class must define `MATCH_REGEXP`.
#
# @example Define `match` class method
#   class MetasploitDataModels::Format
#     extend MetasploitDataModels::Match
#
#     #
#     # CONSTANTS
#     #
#
#     # Regular expression {MetasploitDataModels::Match#match} must match against.
#     MATCH_REGEXP = /\A...\z/
#   end
#
#   # a `MetasploitDataModels::Format` because `'123'` matches `MetasploitDataModels::Format::MATCH_REGEXP`
#   instance = MetapsloitDataModels::Format.match('123')
#   # `nil` because string `'12'` doesn't match `MetasploitDataModels::Format::MATCH_REGEXP`
#   no_instance = MetasploitDataModels::Format.match('12')
#
module MetasploitDataModels::Match
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