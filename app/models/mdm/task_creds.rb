class Mdm::TaskCred < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :cred, :class_name => Mdm::Cred
  belongs_to :task, :class_name =>  Mdm::Task

end
