shared_context 'ActiveRecord attribute_type' do
  def attribute_type(attribute)
    column = base_class.columns_hash.fetch(attribute.to_s)

    column.type
  end
end