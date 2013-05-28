class Mdm::TaskHost < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :host, :class_name => 'Mdm::Host'
  belongs_to :task, :class_name =>  'Mdm::Task'

  validates :host_id,
            :uniqueness => {
                :scope => :task_id
            }
end
