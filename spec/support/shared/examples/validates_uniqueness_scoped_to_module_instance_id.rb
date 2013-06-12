shared_examples_for 'validates uniqueness scoped to module_instance_id' do |options={}|
  options.assert_valid_keys(:factory, :of, :sequence)
  attribute = options.fetch(:of)
  factory = options.fetch(:factory)
  sequence = options.fetch(:sequence)

  let(:error_message) do
    'has already been taken'
  end

  let(:existing_module_instance) do
    FactoryGirl.create(:mdm_module_instance)
  end

  let!(:existing_instance) do
    FactoryGirl.create(factory, :module_instance => existing_module_instance)
  end

  context 'with same module_instance_id' do
    let(:new_instance) do
      FactoryGirl.build(factory, :module_instance => existing_module_instance)
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

  context 'without same module_instance_id' do
    let(:new_module_instance) do
      FactoryGirl.create(:mdm_module_instance)
    end

    let(:new_instance) do
      FactoryGirl.build(factory, :module_instance => new_module_instance)
    end

    it "should allow same #{attribute}" do
      existing_value = existing_instance.send(attribute)
      new_instance.send("#{attribute}=", existing_value)

      new_instance.send(:module_instance_id).should_not == existing_instance.send(:module_instance_id)
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