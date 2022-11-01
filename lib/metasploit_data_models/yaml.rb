# Namespace for YAML configuration
class MetasploitDataModels::YAML
  #
  # CONSTANTS
  #

  # List of supported classes when deserializing YAML classes
  # See: https://discuss.rubyonrails.org/t/cve-2022-32224-possible-rce-escalation-bug-with-serialized-columns-in-active-record/81017
  #
  PERMITTED_CLASSES = [
    Range,
    Set,
    Symbol,
    Time,
    'WEBrick::Cookie'.to_sym,
    'ActionController::Parameters'.to_sym,
    'ActiveModel::Attribute::FromDatabase'.to_sym,
    'ActiveModel::Attribute::FromUser'.to_sym,
    'ActiveModel::Attribute::WithCastValue'.to_sym,
    'ActiveModel::Type::Boolean'.to_sym,
    'ActiveModel::Type::Integer'.to_sym,
    'ActiveModel::Type::String'.to_sym,
    'ActiveRecord::Coders::JSON'.to_sym,
    'ActiveSupport::TimeWithZone'.to_sym,
    'ActiveSupport::TimeZone'.to_sym,
    'ActiveRecord::Type::Serialized'.to_sym,
    'ActiveRecord::Type::Text'.to_sym,
    'ActiveSupport::HashWithIndifferentAccess'.to_sym,
    'Mdm::Workspace'.to_sym
  ].freeze
end
