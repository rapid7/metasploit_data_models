class Mdm::WebPage < ActiveRecord::Base
  
  #
  # Associations
  #

  belongs_to :web_site,
             class_name: 'Mdm::WebSite',
             inverse_of: :web_pages

  #
  # Serializations
  #

  serialize :headers, MetasploitDataModels::Base64Serializer.new
  
  #
  # Mass Assignment Security
  #
  
  # Database Columns
  
  attr_accessible :path, :query, :code, :cookie, :auth, :ctype, :mtime,
                  :location, :headers, :body, :request
  
  # Foreign Keys
  
  attr_accessible :web_site_id
  
  # Model Associations
  
  attr_accessible :web_site
  
  Metasploit::Concern.run(self)
end

