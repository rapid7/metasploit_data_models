class Mdm::WebForm < ActiveRecord::Base
  #
  # Mass Assignment Security
  #

  attr_accessible :path, :method, :params, :query
  
  #
  # Relations
  #

  belongs_to :web_site,
             class_name: 'Mdm::WebSite',
             inverse_of: :web_forms

  #
  # Serializations
  #

  serialize :params, MetasploitDataModels::Base64Serializer.new

  Metasploit::Concern.run(self)
end

