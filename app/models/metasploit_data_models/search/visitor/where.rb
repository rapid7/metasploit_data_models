# Generates AREL to pass to `ActiveRecord::Relation#where` from a `Metasploit::Model::Search::Query`.
class MetasploitDataModels::Search::Visitor::Where
  include Metasploit::Model::Visitation::Visit

  #
  # CONSTANTS
  #

  # `Metasploit::Model::Search::Operation::Base` subclasses that check their value with the equality operator in
  # AREL
  EQUALITY_OPERATION_CLASS_NAMES = [
      'Metasploit::Model::Search::Operation::Boolean',
      'Metasploit::Model::Search::Operation::Date',
      'Metasploit::Model::Search::Operation::Integer'
  ]

  #
  # Visitor
  #

  visit 'Metasploit::Model::Search::Group::Base',
        'Metasploit::Model::Search::Operation::Union' do |parent|
    method = method_visitor.visit parent

    children_arel = parent.children.collect { |child|
      visit child
    }

    children_arel.inject { |group_arel, child_arel|
      group_arel.send(method, child_arel)
    }
  end

  visit *EQUALITY_OPERATION_CLASS_NAMES do |operation|
    attribute = attribute_visitor.visit operation.operator

    attribute.eq(operation.value)
  end

  visit 'Metasploit::Model::Search::Operation::String' do |operation|
    attribute = attribute_visitor.visit operation.operator
    match_value = "%#{operation.value}%"

    attribute.matches(match_value)
	end

  #
  # Methods
  #

  # Visitor for `Metasploit::Model::Search::Operator::Base` subclasses to generate `Arel::Attributes::Attribute`.
  #
  # @return [MetasploitDataModels::Search::Visitor::Attribute]
  def attribute_visitor
    @attribute_visitor ||= MetasploitDataModels::Search::Visitor::Attribute.new
  end

  # Visitor for `Metasploit::Model::Search::Group::Base` subclasses to generate equivalent AREL node methods.
  #
  # @return [MetasploitDataModels::Search::Visitor::Method]
  def method_visitor
    @method_visitor ||= MetasploitDataModels::Search::Visitor::Method.new
  end
end
