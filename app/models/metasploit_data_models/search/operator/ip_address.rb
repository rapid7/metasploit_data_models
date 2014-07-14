class MetasploitDataModels::Search::Operator::IPAddress < Metasploit::Model::Search::Operator::Single
  def operation_class_name
    @operation_class_name ||= 'MetasploitDataModels::Search::Operation::IPAddress'
  end

  # @return [Symbol] `:ip_address`
  def type
    :ip_address
  end
end