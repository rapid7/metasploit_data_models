# Join model between {Mdm::Cred} and {Mdm::Task} that signifies that the {#task} found the {#cred}.
class Mdm::TaskCred < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] cred
  #   The {Mdm::Cred} found by {#task}.
  #
  #   @return [Mdm::Cred]
  belongs_to :cred, :class_name => 'Mdm::Cred'

  # @!attribute [rw] task
  #   An {Mdm::Task} that found {#cred}.
  #
  #   @return [Mdm::Task]
  belongs_to :task, :class_name =>  'Mdm::Task'

  #
  # Attributes
  #

  # @!attribute [rw] created_at
  #   When this task cred was created.
  #
  #   @return [DateTime]

  # @!attribute [rw] updated_at
  #   The last time this task cred was updated.
  #
  #   @return [DateTime]

  #
  # Validations
  #

  validates :cred,
            :presence => true
  validates :cred_id,
            :uniqueness => {
                :scope => :task_id
            }
  validates :task,
            :presence => true
end
