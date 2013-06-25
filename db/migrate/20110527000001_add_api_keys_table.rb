# Creates api_keys.
class AddApiKeysTable < ActiveRecord::Migration
  # Drops api_keys.
  #
  # @return [void]
  def down
    drop_table :api_keys
  end

  # Creates api_keys.
  #
  # @return [void]
	def up
		create_table :api_keys do |t|
			t.text :token
			t.timestamps
		end
	end
end

