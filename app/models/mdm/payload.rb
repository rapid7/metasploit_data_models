class Mdm::Payload < ActiveRecord::Base
  extend ActiveSupport::Autoload

  serialize :urls

end
