class Mdm::TaskHost < ActiveRecord::Base
  belongs_to :host,
             class_name: 'Mdm::Host',
             inverse_of: :task_hosts

  belongs_to :task,
             class_name: 'Mdm::Task',
             inverse_of: :task_hosts

  validates :host_id,
            :uniqueness => {
                :scope => :task_id
            }
end
