# Creates architectures
class CreateArchitectures < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Attributes for seeds
  ATTRIBUTES = [
      {
          :abbreviation => 'armbe',
          :bits => 32,
          :endianness => 'big',
          :family => 'arm',
          :summary => 'Little-endian ARM'
      },
      {
          :abbreviation => 'armle',
          :bits => 32,
          :endianness => 'little',
          :family => 'arm',
          :summary => 'Big-endian ARM'
      },
      {
          :abbreviation => 'cbea',
          :bits => 32,
          :endianness => 'big',
          :family => 'cbea',
          :summary => '32-bit Cell Broadband Engine Architecture'
      },
      {
          :abbreviation => 'cbea64',
          :bits => 64,
          :endianness => 'big',
          :family => 'cbea',
          :summary => '64-bit Cell Broadband Engine Architecture'
      },
      {
          :abbreviation => 'cmd',
          :bits => nil,
          :endianness => nil,
          :family => nil,
          :summary => 'Command Injection'
      },
      {
          :abbreviation => 'java',
          :bits => nil,
          :endianness => 'big',
          :family => nil,
          :summary => 'Java'
      },
      {
          :abbreviation => 'mipsbe',
          :bits => 32,
          :endianness => 'big',
          :family => 'mips',
          :summary => 'Big-endian MIPS'
      },
      {
          :abbreviation => 'mipsle',
          :bits => 32,
          :endianness => 'little',
          :family => 'mips',
          :summary => 'Little-endian MIPS'
      },
      {
          :abbreviation => 'php',
          :bits => nil,
          :endianness => nil,
          :family => nil,
          :summary => 'PHP'
      },
      {
          :abbreviation => 'ppc',
          :bits => 32,
          :endianness => 'big',
          :family => 'ppc',
          :summary => '32-bit Peformance Optimization With Enhanced RISC - Performance Computing'
      },
      {
          :abbreviation => 'ppc64',
          :bits => 64,
          :endianness => 'big',
          :family => 'ppc',
          :summary => '64-bit Performance Optimization With Enhanced RISC - Performance Computing'
      },
      {
          :abbreviation => 'ruby',
          :bits => nil,
          :endianness => nil,
          :family => nil,
          :summary => 'Ruby'
      },
      {
          :abbreviation => 'sparc',
          :bits => nil,
          :endianness => nil,
          :family => 'sparc',
          :summary => 'Scalable Processor ARChitecture'
      },
      {
          :abbreviation => 'tty',
          :bits => nil,
          :endianness => nil,
          :family => nil,
          :summary => '*nix terminal'
      },
      {
          :abbreviation => 'x86',
          :bits => 32,
          :endianness => 'little',
          :family => 'x86',
          :summary => '32-bit x86'
      },
      {
          :abbreviation => 'x86_64',
          :bits => 64,
          :endianness => 'little',
          :family => 'x86',
          :summary => '64-bit x86'
      }
  ]


  # Table being created
  TABLE_NAME = :architectures

  # Removes architectures
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Creates architectures
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.integer :bits, :null => true
      t.string :abbreviation, :null => false
      t.string :endianness, :null => true
      t.string :family, :null => true
      t.string :summary, :null => false
    end

    change_table TABLE_NAME do |t|
      t.index :abbreviation, :unique => true
      t.index :summary, :unique => true
      t.index [:family, :bits, :endianness], :unique => true
    end

    # reset columm information since table was just created
    Mdm::Architecture.reset_column_information

    # Seed rows so that table cannot exist without being properly seeded.
    ATTRIBUTES.each do |attributes|
      begin
        Mdm::Architecture.where(attributes).first_or_create!
      rescue ActiveRecord::RecordInvalid => error
        say("Invalid attributes: #{error.record.attributes.inspect}", true)

        raise
      end
    end
  end
end
