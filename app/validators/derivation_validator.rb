class DerivationValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    derived_value = record.send("derived_#{attribute}")

    if value != derived_value
      record.errors[attribute] << 'must match its derivation'
    end
  end
end