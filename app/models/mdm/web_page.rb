class Mdm::WebPage < ActiveRecord::Base
  #
  # Mass Assignment Security
  #

  attr_accessible :path, :query, :code, :cookie, :auth, :ctype, :mtime, 
                  :location, :headers, :body, :request
  
  #
  # Relations
  #

  belongs_to :web_site,
             class_name: 'Mdm::WebSite',
             inverse_of: :web_pages

  #
  # Serializations
  #

  serialize :headers, MetasploitDataModels::Base64Serializer.new

  Metasploit::Concern.run(self)
end

