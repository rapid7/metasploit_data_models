module MetasploitDataModels
  # Allows declaration of attributes embedded inside a prefs attribute declared with `serialize :prefs`.
  module SerializedPrefs
    # Creates attribute reader and writer for each attribute in `attributes` that will look up and set the attribute as
    # key in the `prefs` Hash.
    #
    # @param attributes [Array<Symbol>] attributes that should have accessors for keys in prefs.
    # @return [void]
    def serialized_prefs_attr_accessor(*attributes)
      attributes.each do |attribute|
        method_declarations = <<-RUBY
          def #{attribute}
            return if not self.prefs
            self.prefs[:#{attribute}]
          end

          def #{attribute}=(value)
            temp = self.prefs || {}
            temp[:#{attribute}] = value
            self.prefs = temp
          end
        RUBY

        class_eval method_declarations, __FILE__, __LINE__
      end
    end
  end
end
