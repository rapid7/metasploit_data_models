class Mdm::TaskCred < ActiveRecord::Base
  belongs_to :cred,
             class_name: 'Mdm::Cred',
             inverse_of: :task_creds

  belongs_to :task,
             class_name: 'Mdm::Task',
             inverse_of: :task_creds

  validates :cred_id,
            :uniqueness => {
                :scope => :task_id
            }
end
