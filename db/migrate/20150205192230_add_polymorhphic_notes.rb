class AddPolymorhphicNotes < ActiveRecord::Migration
  def up
    add_column :notes, :notable_id, :integer
    add_column :notes, :notable_type, :string
    add_index :notes, :notable_id

    Mdm::Note.all do |note|

      unless note.service_id.nil?
        note.notable_type = "Mdm::Service"
        note.notable_id = note.service_id
      end

      unless note.host_id.nil?
        note.notable_type = "Mdm::Host"
        note.notable_id = note.host_id
      end

      note.save

    end

    remove_column :notes, :service_id
    remove_column :notes, :host_id

  end

  def down
    remove_column :notes, :notable_id
    remove_column :notes, :notable_type
    add_column :notes, :service_id, :integer
    add_column :notes, :host_id, :integer
  end
end
