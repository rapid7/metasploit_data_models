module MetasploitDataModels
  module EntityRelationshipDiagram
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
      # @return [Set<Class<ActiveRecord::Base>>]
      def self.models
        MetasploitDataModels.require_models

        class_queue = ActiveRecord::Base.descendants.select { |klass|
          klass.name.starts_with? NAMESPACE
        }
        visited_class_set = Set.new

        until class_queue.empty?
          klass = class_queue.pop
          # add immediately to visited set in case there are recursive associations
          visited_class_set.add klass

          # only iterate belongs_to as they need to be included so that foreign keys aren't let dangling in the ERD.
          reflections = klass.reflect_on_all_associations(:belongs_to)

          reflections.each do |reflection|
            target_klass = reflection.klass

            unless visited_class_set.include? target_klass
              class_queue << target_klass
            end
          end
        end

        visited_class_set
      end
    end
  end
end