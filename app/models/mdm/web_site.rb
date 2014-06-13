class Mdm::WebSite < ActiveRecord::Base
  #
  # Relations
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

  def form_count
    web_forms.size
  end

  def page_count
    web_pages.size
  end

  def to_url(ignore_vhost=false)
    proto = self.service.name == "https" ? "https" : "http"
    host = ignore_vhost ? self.service.host.address : self.vhost
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

  ActiveSupport.run_load_hooks(:mdm_web_site, self)
end

