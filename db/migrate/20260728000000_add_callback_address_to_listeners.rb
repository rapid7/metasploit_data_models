class AddCallbackAddressToListeners < ActiveRecord::Migration[7.0]
  def change
    add_column :listeners, :callback_address, :text
  end
end
