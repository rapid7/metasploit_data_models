# Join model between {Mdm::Host} and {Mdm::Task} that signifies that the {#task} found the {#host}.
class Mdm::TaskHost < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] host
  #   The {Mdm::Host} found by {#task}.
  #
  #   @return [Mdm::Host]
  belongs_to :host, class_name: 'Mdm::Host', inverse_of: :task_hosts

  # @!attribute [rw] task
  #   An {Mdm::Task} that found {#host}.
  #
  #   @return [Mdm::Task]
  belongs_to :task, class_name: 'Mdm::Task', inverse_of: :task_hosts

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

  validates :host,
            :presence => true
  validates :host_id,
            :uniqueness => {
                :scope => :task_id
            }
  validates :task,
            :presence => true
end
