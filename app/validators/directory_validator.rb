class DirectoryValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value and File.directory?(value)
      record.errors[attribute] << "must be a directory"
    end
  end
end