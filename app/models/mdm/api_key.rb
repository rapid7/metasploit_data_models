# API key to access the RPC.
class Mdm::ApiKey < ActiveRecord::Base
  #
  # Attributes
  #

  # @!attribute [rw] created_at
  #   When this API Key was created.
  #
  #   @return [DateTime]

  # @!attribute [rw] token
  #   The API Key to authenicate to the RPC.
  #
  #   @return [String]

  # @!attribute [rw] updated_at
  #   The last time this API Key was updated.
  #
  #   @return [DateTime]

  #
  # Validations
  #

  validate :supports_api

  validates :token,
            :length => {
                :minimum => 8
            },
            :uniqueness => true

  protected

  # Validates whether License supports API.
  #
  # @return [void]
  # @todo https://www.pivotaltracker.com/story/show/52140447
  def supports_api
    begin
      license = License.instance
    rescue NameError
      license = nil
    end

    unless license and license.supports_api?
      errors[:base] = 'is not available because license does not support API access'
    end
  end

  ActiveSupport.run_load_hooks(:mdm_api_key, self)
end
