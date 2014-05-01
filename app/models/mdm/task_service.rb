class Mdm::TaskService < ActiveRecord::Base
  belongs_to :service,
             class_name: 'Mdm::Service',
             inverse_of: :task_services

  belongs_to :task,
             class_name: 'Mdm::Task',
             inverse_of: :task_services

  validates :service_id,
            :uniqueness => {
                :scope => :task_id
            }
end
