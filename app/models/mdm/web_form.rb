# A filled-in form on a {#web_site}.
class Mdm::WebForm < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] web_site
  #   {Mdm::WebSite Web site} on which this form is.
  #
  #   @return [Mdm::WebSite]
  belongs_to :web_site, :class_name => 'Mdm::WebSite'

  #
  # Attributes
  #

  # @!attribute [rw] created_at
  #   When this web form was created.
  #
  #   @return [DateTime]

  # @!attribute [rw] method
  #   HTTP method (or verb) used to submitted this form, such as GET or POST.
  #
  #   @return [String]

  # @!attribute [rw] path
  #   Path portion of URL to which this form was submitted.
  #
  #   @return [String]

  # @!attribute [rw] query
  #   URL query that submitted for this form.
  #
  #   @return [String]

  # @!attribute [rw] updated_at
  #   The last time this web form was updated.
  #
  #   @return [DateTime]

  #
  # Serializations
  #

  # @!attribute [rw] params
  #   Parameters submitted in this form.
  #
  #   @return [Array<Array(String, String)>>]
  serialize :params, MetasploitDataModels::Base64Serializer.new

  ActiveSupport.run_load_hooks(:mdm_web_form, self)
end

