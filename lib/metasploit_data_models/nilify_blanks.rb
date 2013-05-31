module MetasploitDataModels
  # Registers before validation callback to convert the given attributes to `nil` if they are blank.  This can be used
  # to normalize empty attributes to NULL in the database so queries don't have to handle both `= ''` and `IS NULL`.
  module NilifyBlanks
    extend ActiveSupport::Concern

    included do
      before_validation :nilify_blanks
    end

    module ClassMethods
      def nilify_blank(*attributes)
        nilify_blank_attribute_set.merge(attributes)
      end

      def nilify_blank_attribute_set
        @nilify_blank_attribute_set ||= Set.new
      end
    end

    #
    # Instance Methods
    #

    def nilify_blanks
      self.class.nilify_blank_attribute_set.each do |attribute|
        value = read_attribute(attribute)

        if value.respond_to? :blank? and value.blank?
          write_attribute(attribute, nil)
        end
      end
    end
  end
end