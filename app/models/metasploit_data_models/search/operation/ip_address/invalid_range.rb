# Class used when no other {MetasploitDataModels::Search::Operator::IPAddress::Range.operation_classes operation class}
# matches the `formatted_value`.
class MetasploitDataModels::Search::Operation::IPAddress::InvalidRange < Metasploit::Model::Search::Operation::Base
  #
  # Validations
  #

  validate :invalid

  #
  # Class Methods
  #

  # Always matches.
  #
  # @return [MetasploitDataModels::Search::Operator::IPAddress::InvalidRange]
  def self.match(formatted_value)
    new(value: formatted_value)
  end

  #
  # Instance Methods
  #

  private

  # Always marks the operation as invalid because it didn't match any of the format specific
  # {MetasploitDataModel::Search::Operation::IPAddress} operations.
  #
  # @return [void]
  def invalid
    errors.add(:value, :format)
  end
end