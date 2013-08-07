module MetasploitDataModels
  module EntityRelationshipDiagram
    #
    # CONSTANTS
    #

    # Enable all attributes
    ATTRIBUTES = [
        :content,
        :foreign_keys,
        :inheritance,
        :primary_keys,
        :timestamps
    ]

    # Only show direct relationships since the ERD is for use with SQL and there is no need to show has_many :through
    # for those purposes.
    INDIRECT = false

    # Use crowsfoot notation since its what we use for manually drawn diagrams.
    NOTATION = :crowsfoot

    # Default options for {#initialize}
    DEFAULT_OPTIONS = {
        :attributes => ATTRIBUTES,
        :indirect => INDIRECT,
        :notation => NOTATION
    }

    #
    # Methods
    #

    # All {cluster clusters} of classes that are reachable through belongs_to from each ActiveRecord::Base descendant
    #
    # @return [Hash{Class<ActiveRecord::Base> => Set<Class<ActiveRecord::Base>>}] Maps entry point to cluster to its
    #   cluster.
    def self.cluster_by_class
      cluster_by_class = {}

      MetasploitDataModels.require_models

      ActiveRecord::Base.descendants.each do |klass|
        klass_cluster = cluster(klass)
        cluster_by_class[klass] = klass_cluster
      end

      cluster_by_class
    end

    # Cluster of classes that are reachable through belongs_to from `classes`.
    #
    # @param classes [Array<Class<ActiveRecord::Base>>] classes that must be in cluster.  All other classes in the
    #   returned cluster will be classes to which `classes` belong directly or indirectly.
    # @return [Set<Class<ActiveRecord::Base>>]
    def self.cluster(*classes)
      class_queue = classes.dup
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

    # Domain containing all models in this gem.
    #
    # @return [RailsERD::Domain]
    def self.domain
      MetasploitDataModels.require_models

      RailsERD::Domain.generate
    end

    # Set of largest clusters from {cluster_by_class}.
    #
    # @return [Array<Set<Class<ActiveRecord::Base>>>]
    def self.maximal_clusters
      clusters = cluster_by_class.values
      unique_clusters = clusters.uniq

      maximal_clusters = unique_clusters.dup
      cluster_queue = unique_clusters.dup

      until cluster_queue.empty?
        cluster = cluster_queue.pop

        proper_subset = false

        maximal_clusters.each do |maximal_cluster|
          if cluster.proper_subset? maximal_cluster
            proper_subset = true
            break
          end
        end

        if proper_subset
          maximal_clusters.delete(cluster)
        end
      end

      maximal_clusters
    end
  end
end