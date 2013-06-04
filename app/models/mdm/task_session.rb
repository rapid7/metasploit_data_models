class Mdm::TaskSession < ActiveRecord::Base
  belongs_to :session, :class_name => 'Mdm::Session'
  belongs_to :task, :class_name =>  'Mdm::Task'

  validates :session_id,
            :uniqueness => {
                :scope => :task_id
            }
end
