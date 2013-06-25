module MetasploitDataModels
  # Allow to declare that attributes should be derived, which will set the attribute equal to derived_<attribute> if
  # the attribute is `nil` before validation.  Optionally, it can be checked if the attribute matches the
  # derived_<attribute> in a validation.
  #
  #
  # @example Full setup
  #   class Person < ActiveRecord::Base
  #     include MetasploitDataModels::Derivation
  #
  #     #
  #     # Attributes
  #     #
  #
  #     # @!attributes [rw] first_name
  #     #   First Name.
  #     #
  #     #   @return [String]
  #
  #     # @!attribute [rw] full_name
  #     #   Full name. (Includes first and last name).
  #     #
  #     #   @return [String]
  #
  #     # @!attribute [rw] last_name
  #     #   Last name.
  #     #
  #     #   @return [String]
  #
  #     #
  #     # Derivations
  #     #
  #
  #     derives :full_name
  #
  #     #
  #     # Methods
  #     #
  #
  #     # Derives {#full_name} from {#first_name} and {#last_name}.
  #     #
  #     # @return [String] "<first_name> <last_name>"
  #     def derive_full_name
  #       "#{first_name} #{last_name}"
  #     end
  #   end
  module Derivation
    extend ActiveSupport::Concern

    included do
      before_validation :derive
    end

    # Defines class methods include {#derives}, which can be used to declare derived attributes after mixing in
    # {MetasploitDataModels::Derivation}.
    module ClassMethods
      # Declares that the attribute should be derived using the derived_<attribute> method if it is `nil` before
      # validation.
      #
      # @param attribute [Symbol] the name of the attribute.
      # @param options [Hash{Symbol => Boolean}]
      # @option options [Boolean] :validate (false) If `true`, validates `attribute` using {DerivationValidator}.  If
      #   `false`, does no validation on `attribute`.
      # @return [void]
      def derives(attribute, options={})
        options.assert_valid_keys(:validate)

        validate = options.fetch(:validate, false)
        validate_by_derived_attribute[attribute] = validate

        if validate
          validates attribute, :derivation => true
        end
      end

      # Maps a derived attribute (declared with {#derives}) to whether the attribute should validate as a derivation.
      #
      # @return [Hash{Symbol => Boolean}]
      def validate_by_derived_attribute
        @validate_by_derived_attribute ||= {}
      end
    end

    #
    # Instance Methods
    #

    private

    # Derives each attribute in {ClassMethods#validate_by_derived_attribute} if the attribute is `nil`.
    #
    # @return [void]
    def derive
      self.class.validate_by_derived_attribute.each_key do |attribute|
        value = send(attribute)

        # explicitly check for `nil` in case attribute is Boolean
        if value.nil?
          derived_value = send("derived_#{attribute}")
          send("#{attribute}=", derived_value)
        end
      end
    end
  end
end