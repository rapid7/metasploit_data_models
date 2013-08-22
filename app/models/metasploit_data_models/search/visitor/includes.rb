# Gathers all the association names to pass to `ActiveRecord::Relation#includes` from a
# `Metasploit::Model::Search::Query`
class MetasploitDataModels::Search::Visitor::Includes
  include Metasploit::Model::Visitation::Visit

  #
  # Visitors
  #

  visit :module_name => 'Metasploit::Model::Search::Group::Base' do |group|
    group.children.inject([]) { |includes, child|
      child_includes = visit child

      includes.concat(child_includes)
    }
  end

  visit :module_name => 'Metasploit::Model::Search::Operation::Base' do |operation|
    visit operation.operator
  end

  visit :module_name => 'Metasploit::Model::Search::Operator::Association' do |operator|
    [operator.association]
  end

  visit :module_name => 'Metasploit::Model::Search::Operator::Attribute' do |_operator|
    []
  end
end
