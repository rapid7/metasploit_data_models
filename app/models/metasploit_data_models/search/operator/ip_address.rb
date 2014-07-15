class MetasploitDataModels::Search::Operator::IPAddress < Metasploit::Model::Search::Operator::Single
  #
  # Attributes
  #

  # @!attribute [r] attribute
  #   The attribute on `Metasploit::Model::Search::Operator::Base#klass` that is searchable.
  #
  #   @return [Symbol] the attribute name
  attr_accessor :attribute

  #
  # Validations
  #

  validates :attribute,
            presence: true

  #
  # Instance Methods
  #

  alias_method :name, :attribute

  def operation_class_name
    @operation_class_name ||= 'MetasploitDataModels::Search::Operation::IPAddress'
  end

  # @return [Symbol] `:ip_address`
  def type
    :ip_address
  end
end