# Provides ActiveRecord 3.1x-friendly serialization for descendants of
# ApplicationRecord. Backwards compatible with older YAML methods and
# will fall back to string decoding in the worst case
#
# @example Using default default of {}
#   serialize :foo, MetasploitDataModels::Base64Serializer.new
#
# @example Overriding default to []
#   serialize :bar, MetasploitDataModels::Base64Serializer.new(:default => [])
#
class MetasploitDataModels::Base64Serializer
  #
  # CONSTANTS
  #

  # The default for {#default}
  DEFAULT = {}

  # The default for {#coerce}
  COERCE_DEFAULT = false

  # Deserializers for {#load}
  # 1. Base64 decoding and then unmarshalling the value.
  # 2. Parsing the value as YAML.
  # 3. The raw value.
  LOADERS = [
      lambda { |serialized|
        marshaled = serialized.unpack('m').first
        # Load the unpacked Marshal object first
        Marshal.load(marshaled)
      },
      lambda { |serialized|
        # Support legacy YAML encoding for existing data
        YAML.safe_load(serialized, permitted_classes: Rails.application.config.active_record.yaml_column_permitted_classes)
      },
      lambda { |serialized|
        # Fall back to string decoding
        serialized
      }
  ]

  #
  # Methods
  #

  # Creates a duplicate of default value
  #
  # @return
  def default
    @default.dup
  end

  attr_writer :default
  attr_writer :coerce

  # Recursively coerce the object that has been passed in, keeping primitive types as their original type,
  # while changing objects that cannot be serialized into a string representation of the object data.
  def coerce_object(value)
    case value
    when Hash
      value.transform_values { |v| coerce_object(v) }
    when Array
      value.map { |v| coerce_object(v) }
    when File, IO
      value.inspect
    when String, Integer, Float, TrueClass, FalseClass, NilClass, Symbol
      value
    else
      value.to_s
    end
  end

  # Serializes the value by marshalling the value and then base64 encodes the marshaled value.
  #
  # @param value [Object] value to serialize
  # @return [String]
  def dump(value)
    # Always store data back in the Marshal format
    to_serialize = @coerce ? coerce_object(value) : value
    marshalled = Marshal.dump(to_serialize)
    base64_encoded = [ marshalled ].pack('m')

    base64_encoded
  end

  # @param attributes [Hash] attributes
  # @option attributes [Object] :default ({}) Value to use for {#default}.
  def initialize(attributes={})
    attributes.assert_valid_keys(:default, :coerce)

    @default = attributes.fetch(:default, DEFAULT)
    @coerce = attributes.fetch(:coerce, COERCE_DEFAULT)
  end

  # Deserializes the value by either
  # 1. Base64 decoding and then unmarshalling the value.
  # 2. Parsing the value as YAML.
  # 3. Returns the raw value.
  #
  # @param value [String] serialized value
  # @return [Object]
  #
  # @see #default
  def load(value)
    loaded = nil

    if value.blank?
      loaded = default
    else
      LOADERS.each do |loader|
        begin
          loaded = loader.call(value)
        rescue
          next
        else
          break
        end
      end
    end

    loaded
  end
end
