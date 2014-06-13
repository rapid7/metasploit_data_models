class Mdm::TaskSession < ActiveRecord::Base
  belongs_to :session,
             class_name: 'Mdm::Session',
             inverse_of: :task_sessions

  belongs_to :task,
             class_name: 'Mdm::Task',
             inverse_of: :task_sessions

  validates :session_id,
            :uniqueness => {
                :scope => :task_id
            }
end
