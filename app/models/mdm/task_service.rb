# Join model between {Mdm::Service} and {Mdm::Task} that signifies that the {#task} found the {#service}.
class Mdm::TaskService < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] service
  #   The {Mdm::Service} found by {#task}.
  #
  #   @return [Mdm::Service]
  belongs_to :service, class_name: 'Mdm::Service', inverse_of: :task_services

  # @!attribute [rw] task
  #   An {Mdm::Task} that found {#service}.
  #
  #   @return [Mdm::Task]
  belongs_to :task, class_name: 'Mdm::Task', inverse_of: :task_services

  #
  # Attributes
  #

  # @!attribute [rw] created_at
  #   When this task host was created.
  #
  #   @return [DateTime]

  # @!attribute [rw] updated_at
  #   The last time this task cred was updated.
  #
  #   @return [DateTime]

  #
  # Validations
  #

  validates :service,
            :presence => true
  validates :service_id,
            :uniqueness => {
                :scope => :task_id
            }
  validates :task,
            :presence => true
end
