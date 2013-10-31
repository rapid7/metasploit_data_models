# Join model between {Mdm::Session} and {Mdm::Task} that signifies that the {#task} spawned the {#session}.
class Mdm::TaskSession < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] session
  #   The {Mdm::Session} found by {#task}.
  #
  #   @return [Mdm::Session]
  belongs_to :session, class_name: 'Mdm::Session', inverse_of: :task_sessions

  # @!attribute [rw] task
  #   An {Mdm::Task} that found {#session}.
  #
  #   @return [Mdm::Task]
  belongs_to :task, class_name: 'Mdm::Task', inverse_of: :task_sessions

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

  validates :session,
            :presence => true
  validates :session_id,
            :uniqueness => {
                :scope => :task_id
            }
  validates :task,
            :presence => true
end
