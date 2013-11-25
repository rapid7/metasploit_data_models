# Using {#batched_save}, `ActiveRecord::Base#save` will be attempted in a batch mode
# (using {MetasploitDataModels::Batch.batch} block), thereby disabling the uniqueness validations, but if a
# `ActiveRecord::RecordNotUnique` error is raised from the unique index, then the save is retried outside the batch
# mode, so that all validation errors are populated instead of just identifying the irst unique index check that failed
# as would be the case with if the exception were added as a validation error.
#
# @example Using batched save to optimistically avoid uniqueness overhead
#   class MyRecord < ActiveRecord::Base
#     include MetasploitDataModels::Batch::Root
#
#     #
#     # Attributes
#     #
#
#     # @!attribute [rw] unique_field
#     #   A field that is unique
#     #
#     #   @return [Object]
#
#     #
#     # Validations
#     #
#
#     validates :unique_field,
#               uniqueness: {
#                   unless: :batched?
#               }
#   end
#
#   my_record = MyRecord.new(...)
#   saved = my_record.batched_save
module MetasploitDataModels::Batch::Root
  include MetasploitDataModels::Batch::Descendant

  # Attempts to save record while in {MetasploitDataModels::Batch.batch}, which disables costly uniqueness validations.
  # If `ActiveRecord::RecordNotUnique` error is raised because of the underlying unique index in the database, then the
  # save is retried normally.
  #
  # @return (see #recoverable_save)
  def batched_save
    begin
      MetasploitDataModels::Batch.batch {
        recoverable_save
      }
    rescue ActiveRecord::RecordNotUnique
      recoverable_save
    end
  end

  # `save` wrapped in a new transaction/savepoint so that exception raised by save can be rescued and the transaction
  # won't become unusable.
  #
  # @return [true] if save successful
  # @return [false] if save unsucessful
  def recoverable_save
    # do requires_new so that exception won't kill outer transaction
    ActiveRecord::Base.transaction(requires_new: true) {
      save
    }
  end
end
