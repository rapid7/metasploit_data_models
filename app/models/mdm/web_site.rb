class Mdm::WebSite < ActiveRecord::Base
  
  #
  # Associations
  #

  belongs_to :service,
             class_name: 'Mdm::Service',
             foreign_key: 'service_id',
             inverse_of: :web_sites

  has_many :web_forms,
           class_name: 'Mdm::WebForm',
           dependent: :destroy,
           inverse_of: :web_site

  has_many :web_pages,
           class_name: 'Mdm::WebPage',
           dependent: :destroy,
           inverse_of: :web_site

  has_many :web_vulns,
           class_name: 'Mdm::WebVuln',
           dependent: :destroy,
           inverse_of: :web_site

  #
  # Serializations
  #

  serialize :options, ::MetasploitDataModels::Base64Serializer.new

  #
  # Mass Assignment Security
  #
  
  # Database Columns
  
  attr_accessible :vhost, :comments, :options
  
  # Foreign Keys
  
  attr_accessible :service_id
  
  # Model Associations
  
  attr_accessible :service, :web_forms, :web_pages, :web_vulns
  
  def form_count
    web_forms.size
  end

  def page_count
    web_pages.size
  end

  def to_url(ignore_vhost=false)
    proto = self.service.name == "https" ? "https" : "http"
    host = ignore_vhost ? self.service.host.address.to_s : self.vhost
    port = self.service.port

    if Rex::Socket.is_ipv6?(host)
      host = "[#{host}]"
    end

    url = "#{proto}://#{host}"
    if not ((proto == "http" and port == 80) or (proto == "https" and port == 443))
      url += ":#{port}"
    end
    url
  end

  def vuln_count
    web_vulns.size
  end

  Metasploit::Concern.run(self)
end

