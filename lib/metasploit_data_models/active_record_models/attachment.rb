module MetasploitDataModels::ActiveRecordModels::Attachment
  def self.included(base)
    base.class_eval {
      has_and_belongs_to_many :email_template, :class_name => "Mdm::EmailTemplate"
      belongs_to :campaign, :class_name => "Mdm::Campaign"

      validates_presence_of :data
      validates_format_of :data, :with =>/.{10}/

      # Generate a unique Content-ID
      def cid
        @cid ||= Rex::Text.to_hex(name + id.to_s, '')
        @cid
      end
    }
  end
end
