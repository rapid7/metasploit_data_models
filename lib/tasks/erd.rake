if defined? RailsERD

  namespace :erd do
    create = ->(domain, options={}) {
      merged_options = MetasploitDataModels::EntityRelationshipDiagram::DEFAULT_OPTIONS.merge(
          options
      )
      diagram = RailsERD::Diagram::Graphviz.new(domain, merged_options)
      path = diagram.create

      say "Entity-Relation Diagram saved to #{path}"
    }

    namespace :mdm do
      desc "Generates a pdf containing an Entity-Relationship Diagram for all Mdm::Module models"
      task :module => :require do
        domain = MetasploitDataModels::EntityRelationshipDiagram::Module.domain
        create.call(
            domain,
            :filename => 'mdm-module.erd',
            :title => 'Mdm::Module (Direct) Entity-Relationship Diagram',
        )
      end
    end

    desc "Generates a pdf containing an Entity-Relationship Diagram for all Mdm models"
    task :mdm => :require do
      domain = MetasploitDataModels::EntityRelationshipDiagram.domain
      create.call(
          domain,
          :filename => 'mdm.erd',
          :title => 'Mdm (Direct) Entity-Relationship Diagram'
      )
    end

    task :require => :environment do
      require 'rails_erd/diagram/graphviz'
    end
  end

  desc "Generates a pdf containing an Entity-Relationship Diagram for all Mdm models"
  task :erd => 'erd:mdm'
end