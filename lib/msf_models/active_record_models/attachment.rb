module MsfModels::ActiveRecordModels::Attachment
  def self.included(base)
    base.class_eval{
      has_and_belongs_to_many :email_template
      belongs_to :campaign

      # Generate a unique Content-ID
      def cid
        @cid ||= Rex::Text.to_hex(name + id.to_s, '')
        @cid
      end
    }
  end
end
