class UpdateSerializedTasks < ActiveRecord::Migration[4.2]
  def self.up
    {
        Mdm::Event => [ :info ],
        Mdm::Listener => [ :options ],
        # Mdm::Loot => [ :data ],
        Mdm::Macro => [ :actions, :prefs ],
        Mdm::NexposeConsole => [ :cached_sites ],
        # Mdm::Note => [ :data ],
        Mdm::Session => [ :datastore ],
        Mdm::Task => [ :options, :result, :settings ],
        Mdm::User => [ :prefs ],
        Mdm::WebForm => [ :params ],
        Mdm::WebPage => [ :headers ],
        Mdm::WebSite => [ :options ],
        Mdm::WebVuln => [ :params ]
    }
    Mdm::Task.all.each do |task|
      if task.settings.kind_of?(String)
        begin
          updated_settings = attempt_rails_decode(task.settings)
          task.settings = updated_settings
          task.save
        rescue
          # noop
        end
      end
    end
  end

  def self.down
  end

  def attempt_rails_decode(serialized)
    marshaled = serialized.unpack('m').first
    marshaled = marshaled.gsub('!ActionController::Parameters', '-ActiveSupport::HashWithIndifferentAccess')
    # Load the unpacked Marshal object first
    Marshal.load(marshaled)
  end
end
