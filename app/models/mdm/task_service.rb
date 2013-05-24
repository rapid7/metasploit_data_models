class Mdm::TaskService < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :service, :class_name => Mdm::Service
  belongs_to :task, :class_name =>  Mdm::Task

  validates :service_id,
            :uniqueness => {
                :scope => :task_id
            }
end
