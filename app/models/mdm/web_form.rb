class Mdm::WebForm < ActiveRecord::Base
  
  #
  # Associations
  #

  belongs_to :web_site,
             class_name: 'Mdm::WebSite',
             inverse_of: :web_forms

  #
  # Serializations
  #

  serialize :params, MetasploitDataModels::Base64Serializer.new

  #
  # Mass Assignment Security
  #
  
  # Database Columns
  
  attr_accessible :path, :method, :params, :query
  
  # Foreign Keys
  
  attr_accessible :web_site_id
  
  # Model Associations
  
  attr_accessible :web_site
  
  Metasploit::Concern.run(self)
end

