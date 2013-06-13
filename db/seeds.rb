architecture_attributes = [
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

architecture_attributes.each do |attributes|
  Mdm::Architecture.where(attributes).first_or_create!
end

Mdm::Module::Rank::NUMBER_BY_NAME.each do |name, number|
  Mdm::Module::Rank.where(:name => name, :number => number).first_or_create!
end