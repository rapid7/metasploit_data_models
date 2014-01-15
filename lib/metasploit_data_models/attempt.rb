# Code common to {Mdm::ExploitAttempt} and {Mdm::VulnAttempt}.
module MetasploitDataModels::Attempt
  extend ActiveSupport::Concern

  included do
    #
    # Validations
    #

    validates :attempted_at,
              presence: true
    validates :exploited,
              inclusion: {
                  in: [
                      false,
                      true
                  ]
              }
    validates :module_class,
              presence: true
    validates :vuln,
              presence: true
    validates :username,
              presence: true
  end

  #
  # Methods
  #

  # @deprecated Use #module_class to get the {Mdm::Module::Class} and then access {Mdm::Module::Class#full_name}.
  #
  # The full name of the module's class that attempted this exploit.
  #
  # @return [String] an {Mdm::Module::Class#full_name}
  # @todo Remove deprecated Mdm::*Exploit#module (MSP-9281)
  def module
    ActiveSupport::Deprecation.warn(
        "#{self.class}#module is deprecated.  " \
        "Use #{self.class}#module_class to get the Mdm::Module::Class and then access Mdm::Module::Class#full_name."
    )
    super
  end

  # @deprecated Set #module_class association.
  #
  # Sets the full name of the module's class that attempted this exploit.
  #
  # @param full_name [String] an {Mdm::Module::Class#full_name}
  # @return [void]
  # @todo Remove deprecated Mdm::*Exploit#module (MSP-9281)
  def module=(full_name)
    ActiveSupport::Deprecation.warn(
        "#{self.class}#module= is deprecated.  " \
        "Set #{self.class}#module_class association instead."
    )
    super
  end
end