# Gathers all the association names to pass to `ActiveRecord::Relation#includes` from a
# `Metasploit::Model::Search::Query`
class MetasploitDataModels::Search::Visitor::Includes
  include Metasploit::Model::Visitation::Visit

  #
  # Visitors
  #

  visit 'Metasploit::Model::Search::Group::Base',
        'Metasploit::Model::Search::Operation::Union' do |parent|
    parent.children.flat_map { |child|
      visit child
    }
	end

  visit 'Metasploit::Model::Search::Operation::Base' do |operation|
    visit operation.operator
  end

  visit 'Metasploit::Model::Search::Operator::Association' do |operator|
    [operator.association]
  end

  visit 'Metasploit::Model::Search::Operator::Attribute' do |_operator|
    []
  end

  Metasploit::Concern.run(self)
end
