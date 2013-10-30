module MetasploitDataModels
  module EntityRelationshipDiagram
    # Generate Entity-Relationship Diagrams (ERD) {domain domains} for models under {Mdm::Module}.
    module Module
      #
      # CONSTANTS
      #

      # Namespace for module cache models
      NAMESPACE = 'Mdm::Module'

      #
      # Methods
      #

      # Domain for all Mdm::Module models and their dependencies belongs_to dependencies.
      #
      # @return [RailsERD::Domain]
      def self.domain
        RailsERD::Domain.new(
            models,
            # don't warn about missing entities in domain since has_many associations outside of the domain are
            # purposefully not included in the domain.
            :warn => false
        )
      end

      # Models under Mdm::Module or that are needed by those models through belongs_to associations.
      #
      # @return (see MetasploitDataModels::EntityRelationshipDiagram.cluster)
      def self.models
        MetasploitDataModels::EntityRelationshipDiagram.require_models

        classes = ActiveRecord::Base.descendants.select { |klass|
          klass.name.starts_with? NAMESPACE
        }

        cluster = MetasploitDataModels::EntityRelationshipDiagram.cluster(*classes)

        cluster
      end
    end
  end
end