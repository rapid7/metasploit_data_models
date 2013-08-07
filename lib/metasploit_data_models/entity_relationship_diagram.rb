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

    # Domain containing all models in this gem.
    #
    # @return [RailsERD::Domain]
    def self.domain
      MetasploitDataModels.require_models

      RailsERD::Domain.generate
    end

    def self.filename
      'erd'
    end
  end
end