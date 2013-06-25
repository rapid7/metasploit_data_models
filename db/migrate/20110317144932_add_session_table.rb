# Creates sessions and session_events and migrates sessions and session_events data out of events table.
class AddSessionTable < ActiveRecord::Migration
  # Model to help with extracting data from events table.
  class Event < ActiveRecord::Base
    #
    # Serializations
    #

    # @!attribute [rw] info
    #   @return [Hash]
    serialize :info
  end

  # Model to help with importing data into sessions table.
  class Session < ActiveRecord::Base
    #
    # Associations
    #

    # @!attribute [rw] events
    #   Events that occurred in this session.
    #
    #   @return [Array<AddSessionTable::SessionEvent>]
    has_many :events, :class_name => 'AddSessionTable::SessionEvent'

    #
    # Serializations
    #

    # @!attribute [rw] datastore
    #   Datastore inherited from module used to gain session.
    #
    #   @return [Hash]
    serialize :datastore
  end

  # Model to help with importing data into session_events table.
  class SessionEvent < ActiveRecord::Base
    #
    # Associtations
    #

    # @!attribute [rw] session
    #   Session in which this event occurred.
    #
    #   @return [AddSessionTable::Session]
    belongs_to :session
  end

  # Drops sessions and session_events.
  #
  # @return [void]
  def self.down
    drop_table :sessions
    drop_table :session_events
  end

  # Creates sessions and session_events and migrates sessions and session_events data out of events table.
  #
  # @return [void]
  def up
    create_table :sessions do |t|
      t.integer :host_id

      t.string  :stype       # session type: meterpreter, shell, etc
      t.string  :via_exploit # module name
      t.string  :via_payload # payload name
      t.string  :desc        # session description
      t.integer :port
      t.string  :platform    # platform type of the remote system
      t.string  :routes

      t.text    :datastore   # module's datastore

      t.timestamp :opened_at, :null => false
      t.timestamp :closed_at

      t.string :close_reason
    end

    create_table :session_events do |t|
      t.integer :session_id

      t.string  :etype # event type: command, output, upload, download, filedelete
      t.binary  :command
      t.binary  :output
      t.string  :remote_path
      t.string  :local_path

      t.timestamp :created_at
    end

    #
    # Migrate session data from events table
    #

    close_events = Event.find_all_by_name("session_close")
    open_events  = Event.find_all_by_name("session_open")

    command_events  = Event.find_all_by_name("session_command")
    output_events   = Event.find_all_by_name("session_output")
    upload_events   = Event.find_all_by_name("session_upload")
    download_events = Event.find_all_by_name("session_download")

    open_events.each do |o|
      c = close_events.find { |e| e.info[:session_uuid] == o.info[:session_uuid] }

      s = Session.new(
          :host_id => o.host_id,
          :stype => o.info[:session_type],
          :via_exploit => o.info[:via_exploit],
          :via_payload => o.info[:via_payload],
          :datastore => o.info[:datastore],
          :opened_at => o.created_at
      )

      if c
        s.closed_at = c.created_at
        s.desc = c.info[:session_info]
      else
        # couldn't find the corresponding close event
        s.closed_at = s.opened_at
        s.desc = "?"
      end

      uuid = o.info[:session_uuid]

      command_events.select { |e| e.info[:session_uuid] == uuid }.each do |e|
        s.events.build(:created_at => e.created_at, :etype => "command", :command => e.info[:command] )
      end

      output_events.select { |e| e.info[:session_uuid] == uuid }.each do |e|
        s.events.build(:created_at => e.created_at, :etype => "output", :output => e.info[:output] )
      end

      upload_events.select { |e| e.info[:session_uuid] == uuid }.each do |e|
        s.events.build(:created_at => e.created_at, :etype => "upload", :local_path => e.info[:local_path], :remote_path  => e.info[:remote_path] )
      end

      download_events.select { |e| e.info[:session_uuid] == uuid }.each do |e|
        s.events.build(:created_at => e.created_at, :etype => "download", :local_path => e.info[:local_path], :remote_path  => e.info[:remote_path] )
      end

      s.events.sort_by(&:created_at)

      s.save!
    end
  end
end
