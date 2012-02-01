module MsfModels::ActiveRecordModels::EmailTemplate
  def self.included(base)
    base.class_eval {
      belongs_to :campaign, :class_name => "Msm::Campaign"
      # XXX: For some reason, assigning the attachments attribute of one
      # email_template object to another's gives us twice as many as we need.
      # Adding :uniq here fixes the display by ignoring duplicates when fetching,
      # but we still have extra records in the join table that aren't needed
      # XXX: This is a rails bug.  And :uniq doesn't appear to fix it in all
      # situations.  We also have to do +template.attachments.uniq!+ in some
      # places.
      # http://ryanbigg.com/2010/04/has_and_belongs_to_many-double-insert/
      has_and_belongs_to_many :attachments, :uniq => true, :class_name => "Msm::Attachment"
      belongs_to :email_template, :foreign_key => :parent_id, :class_name => "Msm::EmailTemplate"
      has_one :email_template, :foreign_key => :parent_id, :class_name => "Msm::EmailTemplate"

      extend MsfModels::SerializedPrefs

      serialize :prefs, MsfModels::Base64Serializer.new

      serialized_prefs_attr_accessor :exploit_module, :exploit_attach_name
      serialized_prefs_attr_accessor :attach_exe
      serialized_prefs_attr_accessor :attach_exploit

      before_save :fix_bools

      validates_associated :attachments

      private

      def fix_bools
        bools = ["attach_exe", "attach_exploit"]

        bools.each do |b|
          if self.send(b) == "0" or self.send(b).blank?
            self.send(b+"=", false)
          else
            self.send(b+"=", true)
          end
        end

        true
      end
    }
  end
end

