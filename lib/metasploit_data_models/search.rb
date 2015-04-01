# Namespace that deals with search {Mdm} models.
module MetasploitDataModels
  module Search
    extend ActiveSupport::Autoload

    autoload :Operation
    autoload :Operator
    autoload :Visitor
  end
end