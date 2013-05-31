shared_examples_for 'validates uniqueness scoped to detail_id' do |options={}|
  options.assert_valid_keys(:factory, :of, :sequence)
  attribute = options.fetch(:of)
  factory = options.fetch(:factory)
  sequence = options.fetch(:sequence)

  let(:error_message) do
    'has already been taken'
  end

  let(:existing_detail) do
    FactoryGirl.create(:mdm_module_detail, :parent_path => existing_parent_path)
  end

  let!(:existing_instance) do
    FactoryGirl.create(factory, :detail => existing_detail)
  end

  let(:existing_parent_path) do
    FactoryGirl.create(:mdm_module_path)
  end

  context 'with same detail_id' do
    let(:new_instance) do
      FactoryGirl.build(factory, :detail => existing_detail)
    end

    it "should not allow same #{attribute}" do
      existing_value = existing_instance.send(attribute)
      new_instance.send("#{attribute}=", existing_value)

      new_instance.send(attribute).should == existing_value
      new_instance.should_not be_valid
      new_instance.errors[attribute].should include(error_message)
    end

    it "should allow different #{attribute}" do
      new_value = FactoryGirl.generate sequence
      new_instance.send("#{attribute}=", new_value)

      new_instance.send(attribute).should_not == existing_instance.send(attribute)
      new_instance.should be_valid
      new_instance.errors[attribute].should_not include(error_message)
    end
  end

  context 'without same detail_id' do
    let(:new_detail) do
      # Reuse the same parent_path so that a new directory under dummy doesn't need to be created and removed
      FactoryGirl.create(:mdm_module_detail, :parent_path => existing_parent_path)
    end

    let(:new_instance) do
      FactoryGirl.build(factory, :detail => new_detail)
    end

    it "should allow same #{attribute}" do
      existing_value = existing_instance.send(attribute)
      new_instance.send("#{attribute}=", existing_value)

      new_instance.send(:detail_id).should_not == existing_instance.send(:detail_id)
      new_instance.should be_valid
      new_instance.errors[attribute].should_not include(error_message)
    end

    it "should allow different #{attribute}" do
      new_value = FactoryGirl.generate sequence
      new_instance.send("#{attribute}=", new_value)

      new_instance.send(attribute).should_not == existing_instance.send(attribute)
      new_instance.should be_valid
      new_instance.errors[attribute].should_not include(error_message)
    end
  end
end