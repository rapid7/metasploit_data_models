module MsfModels
  module SharedValidations
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def validates_ip_address(ip_attr)
        validates_format_of ip_attr, :with => /\A(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\Z/, :message => "must be an IPv4 address"
      end
    end

  end
end

