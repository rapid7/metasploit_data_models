# Extracts which AREL method to use as a translation for `Metasploit::Model::Search::Group::Base` subclasses.
class MetasploitDataModels::Search::Visitor::Method
  include Metasploit::Model::Visitation::Visit

  visit :module_name => 'Metasploit::Model::Search::Group::Intersection' do
    :and
  end

  visit :module_name => 'Metasploit::Model::Search::Group::Union' do
    :or
  end
end
