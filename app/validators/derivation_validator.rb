# Validator for {MetasploitDataModels::Derivation::ClassMethods#derives}.
class DerivationValidator < ActiveModel::EachValidator
  # Validates that `attribute`'s `value` equals derived_<attribute>'s value.  If they are not equal then the error
  # message is `'must match its derivation'`.
  #
  # @param record [#errors, ActiveRecord::Base] ActiveModel or ActiveRecord
  # @param attribute [Symbol] name of derived attribute.
  # @param value [Object] value of `attribute` in `record`.
  # @return [void]
  def validate_each(record, attribute, value)
    derived_value = record.send("derived_#{attribute}")

    if value != derived_value
      record.errors[attribute] << 'must match its derivation'
    end
  end
end