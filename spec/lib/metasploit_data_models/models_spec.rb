require 'spec_helper'

describe MetasploitDataModels::Models do
  subject(:base_module) do
    described_class = self.described_class

    Module.new do
      extend described_class

      def self.app_pathname
        MetasploitDataModels.root.join('spec', 'dummy', 'app')
      end
    end
  end

  context 'models_pathname' do
    subject(:models_pathname) do
      base_module.models_pathname
    end

    it 'should be app/models' do
      models_pathname.to_path.should end_with('app/models')
    end
  end

  context 'require_models' do
    subject(:require_models) do
      base_module.require_models
    end

    it 'should find all *.rb files under app/models' do
      Dir.should_receive(:glob).with(base_module.models_pathname.join('**', '*.rb'))

      require_models
    end

    it 'should require each file the glob finds' do
      model_paths = [
          double('Model Path 1'),
          double('Model Path 2')
      ]
      Dir.stub(:glob).and_yield(model_paths[0]).and_yield(model_paths[1])

      model_paths.each do |model_path|
        base_module.should_receive(:require).with(model_path)
      end

      require_models
    end
  end
end