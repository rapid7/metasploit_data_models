module IPAddrExtensions
  extend ActiveSupport::Concern

  def coerce(other)
    begin
      case other
      when IPAddr
        other
      when String
        self.class.new(other)
      else
        self.class.new(other, @family)
      end
    rescue ArgumentError => e
      OpenStruct.new(family: false, to_i: false)
    end
  end

  def include?(other)
    begin
      super(other)
    rescue IPAddr::InvalidAddressError
      false
    end
  end
  
end

IPAddr.send(:prepend, IPAddrExtensions)
