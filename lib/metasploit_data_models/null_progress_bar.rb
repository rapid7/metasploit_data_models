# Progress bar that does nothing, for when the consumer of {Mdm::Module::Path#each_changed_module_ancestor} did not
# pass a `:progress_bar`.  Using a NullObject allows the removal of branching logic from the code every time the
# progress bar is accessed.
class MetasploitDataModels::NullProgressBar
  # Sets total length of the progress bar, but this value is thrown away because this is NullObject.
  #
  # @param total [Integer, Float] total progress length
  # @return [void]
  def total=(total)

  end

  # Increment progress toward total, but is a no-op because this is a NullObject.
  #
  # @return [void]
  def increment

  end
end