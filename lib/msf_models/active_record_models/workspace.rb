# NOTE: this AR model is called "Project" on the Pro side

module MsfModels::ActiveRecordModels::Workspace
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave

      # Usage of the evil eval avoids dynamic constant assignment
      # exception when this module is included
      eval('DEFAULT = "default"') unless defined? DEFAULT

      has_many :hosts, :dependent => :destroy
      has_many :services, :through => :hosts
      has_many :notes, :dependent => :destroy
      has_many :loots, :dependent => :destroy
      has_many :events,:dependent => :destroy
      has_many :reports, :dependent => :destroy
      has_many :report_templates, :dependent => :destroy
      has_many :tasks,   :dependent => :destroy
      has_many :clients,  :through => :hosts
      has_many :vulns,    :through => :hosts
      has_many :creds,    :dependent => :destroy
      has_many :imported_creds,  :dependent => :destroy
      has_many :exploited_hosts, :through => :hosts
      has_many :sessions, :through => :hosts
      has_many :cred_files, :dependent => :destroy
      has_many :listeners, :dependent => :destroy

      before_save :normalize

      validates :name, :presence => true, :uniqueness => true, :length => {:maximum => 255}
      validates :description, :length => {:maximum => 4096}
      validate :boundary_must_be_ip_range

      def web_sites
        query = <<-EOQ
          SELECT DISTINCT web_sites.*
            FROM hosts, services, web_sites
            WHERE hosts.workspace_id = #{id} AND
            services.host_id = hosts.id AND
            web_sites.service_id = services.id
          EOQ
        WebSite.find_by_sql(query)
      end

      def web_pages
        query = <<-EOQ
          SELECT DISTINCT web_pages.*
            FROM hosts, services, web_sites, web_pages
            WHERE hosts.workspace_id = #{id} AND
            services.host_id = hosts.id AND
            web_sites.service_id = services.id AND
            web_pages.web_site_id = web_sites.id
        EOQ
        WebPage.find_by_sql(query)
      end

      def web_forms
        query = <<-EOQ
          SELECT DISTINCT web_forms.*
          FROM hosts, services, web_sites, web_forms  
          WHERE hosts.workspace_id = #{id} AND   
            services.host_id = hosts.id AND   
            web_sites.service_id = services.id AND  
            web_forms.web_site_id = web_sites.id
        EOQ
        WebForm.find_by_sql(query)
      end

      def unique_web_forms
        query = <<-EOQ
          SELECT DISTINCT web_forms.web_site_id, web_forms.path, web_forms.method, web_forms.query  
            FROM hosts, services, web_sites, web_forms  
            WHERE hosts.workspace_id = #{id} AND        
            services.host_id = hosts.id AND         
            web_sites.service_id = services.id AND  
            web_forms.web_site_id = web_sites.id
        EOQ
        WebForm.find_by_sql(query)
      end

      def web_vulns
        query = <<-EOQ
          SELECT DISTINCT web_vulns.*  
          FROM hosts, services, web_sites, web_vulns  
            WHERE hosts.workspace_id = #{id} AND  
            services.host_id = hosts.id AND  
            web_sites.service_id = services.id AND  
            web_vulns.web_site_id = web_sites.id
        EOQ
        WebVuln.find_by_sql(query)
      end

      def self.default
        find_or_create_by_name(DEFAULT)
      end

      def default?
        name == DEFAULT
      end

      def creds
        Msm::Cred.find(
          :all,
          :include => {:service => :host},
          :conditions => ["hosts.workspace_id = ?", self.id]
        )
      end

      def host_tags
        Msm::Tag.find(
          :all,
          :include => :hosts,
          :conditions => ["hosts.workspace_id = ?", self.id]
        )
      end

      #
      # This method iterates the creds table calling the supplied block with the
      # cred instance of each entry.
      #
      def each_cred(&block)
        creds.each do |cred|
          block.call(cred)
        end
      end

      def each_host_tag(&block)
        host_tags.each do |host_tag|
          block.call(host_tag)
        end
      end

      def web_unique_forms(addrs=nil)
        forms = unique_web_forms
        if addrs
          forms.reject!{|f| not addrs.include?( f.web_site.service.host.address ) }
        end
        forms
      end

      def boundary_must_be_ip_range
        errors.add(:boundary, "must be a valid IP range") unless valid_ip_or_range?(boundary)
      end

    private
      def valid_ip_or_range?(string)
        begin
          Rex::Socket::RangeWalker.new(string)
        rescue
          return false
        end
      end

      def normalize
        boundary.strip! if boundary
      end

    } # end class_eval block
  end
end

