# Validates that a path is a directory on-disk.
class DirectoryValidator < ActiveModel::EachValidator
  # Validates that `value` is a path to a directory on-disk.  Only records an error if `value` is set and not a
  # directory.  The error is `'must be a directory'`.
  #
  # @param record [#errors, ActiveRecord::Base] ActiveModel or ActiveRecord
  # @param attribute [Symbol] name of directory attribute.
  # @param value [String, nil] path to directory.
  # @return [void]
  def validate_each(record, attribute, value)
    unless value and File.directory?(value)
      record.errors[attribute] << "must be a directory"
    end
  end
end