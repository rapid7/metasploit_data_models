# Common behavior for ranges under {MetasploitDataModels::IPAddress}, including ranges of addresses and segments.
module MetasploitDataModels::IPAddress::Range
  # so that translations for error messages can be filed under metasploit_data_models/ip_address/range
  extend ActiveModel::Naming
  extend ActiveSupport::Concern

  #
  # CONSTANTS
  #

  # The name of the extremes of a range.
  EXTREMES = [
      :begin,
      :end
  ]

  # Separator between the {#begin} and {#end} in the formatted value.
  SEPARATOR = '-'

  #
  # Attributes
  #

  # @!attribute value
  #   The range.
  #
  #   @return [Range<Object, Objectr>] Range with {ClassMethods#extreme_class} instances for `Range#begin` and
  #     `Range#end`.
  #   @return [String] if `formatted_value` cannot be parsed into a Range.
  attr_reader :value

  included do
    include ActiveModel::Validations

    #
    #
    # Validations
    #
    #

    #
    # Validation Methods
    #

    validate :extremes_valid
    validate :order

    #
    # Validation Attributes
    #

    validates :begin,
              presence: true
    validates :end,
              presence: true

  end


  module ClassMethods
    def match_regexp
      @match_regexp ||= /\A#{regexp}\z/
    end

    def extreme_class
      @extreme_class ||= extreme_class_name.constantize
    end

    def extreme_class_name
      @extreme_class_name
    end

    def extremes(options={})
      options.assert_valid_keys(:class_name)

      @extreme_class_name = options.fetch(:class_name)
    end

    def regexp
      @regexp ||= /#{extreme_class.regexp}#{SEPARATOR}#{extreme_class.regexp}/
    end
  end

  #
  # Instance Methods
  #

  # Begin of segment range.
  #
  # @return [MetasploitDataModels::IPAddress::V4::NMAP::Segment::Number] if {#value} is a `Range`.
  # @return [nil] if {#value} is not a `Range`.
  def begin
    if value.respond_to? :begin
      value.begin
    end
  end

  # End of segment range.
  #
  # @return [MetasploitDataModels::IPAddress::V4::NMAP::Segment::Number] if {#value} is a `Range`.
  # @return [nil] if {#value} is not a `Range`.
  def end
    if value.respond_to? :end
      value.end
    end
  end

  # This range as a string.  Equivalent to the original `formatted_value` passed to {#value}.
  #
  # @return [String]
  def to_s
    "#{self.begin}#{SEPARATOR}#{self.end}"
  end

  # Sets {#value} by breaking up the range into its begin and end Integers.
  #
  # @param formatted_value [#to_s]
  # @return [Range<Integer, Integer>] if {SEPARATOR} is used and both extremes are Integers.
  # @return [#to_s] `formatted_value` if it could not be converted
  def value=(formatted_value)
    formatted_extremes = formatted_value.to_s.split(SEPARATOR, 2)

    extremes = formatted_extremes.map { |formatted_extreme|
      self.class.extreme_class.new(value: formatted_extreme)
    }

    begin
      @value = Range.new(*extremes)
    rescue ArgumentError
      @value = formatted_value
    end
  end

  private

  # Validates that {#begin} and {#end} are valid.
  #
  # @return [void]
  def extremes_valid
    EXTREMES.each do |extreme_name|
      extreme_value = send(extreme_name)

      unless extreme_value.respond_to?(:valid?) && extreme_value.valid?
        errors.add(extreme_name, :invalid)
      end
    end
  end

  # Validates that {#begin} is `<=` {#end}.
  #
  # @return [void]
  def order
    if self.begin && self.end && self.begin > self.end
      errors.add(:value, :order, begin: self.begin, end: self.end)
    end
  end
end