RSpec::Matchers.define :validate_directory_at do |attribute|
  directory_pathname = MetasploitDataModels.root.join('spec')
  file_pathname = MetasploitDataModels.root.join('Gemfile')
  error_message = 'must be a directory'

  match do |record|
    setter = "#{attribute}="

    record.send(setter, file_pathname.to_path)
    file_fails = record.invalid?
    file_error = record.errors[attribute].include?(error_message)

    record.send(setter, directory_pathname.to_path)
    # don't capture whether record is valid because it may be invalid because of other validations, but do call it to
    # reset record.errors for new value for attribute.
    record.valid?
    no_directory_error = !record.errors[attribute].include?(error_message)


    if file_fails and file_error and no_directory_error
      true
    else
      false
    end
  end
end