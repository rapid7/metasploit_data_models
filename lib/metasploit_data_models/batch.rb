# Enables use of batch mode in `Thread` inside a {batch} block.  Code, such as uniqueness validations can check if they
# are being called from inside a {batch} block by querying {batched?}.
module MetasploitDataModels::Batch
  #
  # CONSTANTS
  #

  # Thread local variable that is `true` in {batch} block.
  THREAD_LOCAL_VARIABLE_NAME = :metasploit_data_models_batch

  #
  # Methods
  #

  # Inside the block, {batched?} will be true, so in practice, when uniqueness validations should be disabled, wrap the
  # code in `MetasploitDataModels::Batch.batch { ... }`.
  #
  # @yield batched block
  # @yieldreturn value to return from this method
  # @return value returned from block
  def self.batch
    yieldreturn = nil

    before = Thread.current[THREAD_LOCAL_VARIABLE_NAME]
    Thread.current[THREAD_LOCAL_VARIABLE_NAME] = true

    begin
      yieldreturn = yield
    ensure
      Thread.current[THREAD_LOCAL_VARIABLE_NAME] = before
    end

    yieldreturn
  end

  # Whether this `Thread` is in batch mode or not.
  #
  # @return [true] if in batch mode
  # @return [false] otherwise
  def self.batched?
    !!Thread.current[THREAD_LOCAL_VARIABLE_NAME]
  end
end