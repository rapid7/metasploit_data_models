# Extracts which AREL method to use as a translation for `Metasploit::Model::Search::Group::Base` subclasses.
class MetasploitDataModels::Search::Visitor::Method
  include Metasploit::Model::Visitation::Visit

  visit 'Metasploit::Model::Search::Group::Intersection' do
    :and
  end

  visit 'Metasploit::Model::Search::Group::Union',
        'Metasploit::Model::Search::Operation::Union' do
    :or
  end
end
