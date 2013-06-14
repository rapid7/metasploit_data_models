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


authority_attributes = [
    {
        :abbreviation => 'BID',
        :obsolete => false,
        :summary => 'BuqTraq ID',
        :url => 'http://www.securityfocus.com/bid'
    },
    {
        :abbreviation => 'CVE',
        :obsolete => false,
        :summary => 'Common Vulnerabilities and Exposures',
        :url => 'http://cvedetails.com'
    },
    {
        :abbreviation => 'MIL',
        :obsolete => true,
        :summary => 'milw0rm',
        :url => 'https://en.wikipedia.org/wiki/Milw0rm'
    },
    {
        :abbreviation => 'MSB',
        :obsolete => false,
        :summary => 'Microsoft Security Bulletin',
        :url => 'http://www.microsoft.com/technet/security/bulletin'
    },
    {
        :abbreviation => 'OSVDB',
        :obsolete => false,
        :summary => 'Open Sourced Vulnerability Database',
        :url => 'http://osvdb.org'
    },
    {
        :abbreviation => 'PMASA',
        :obsolete => false,
        :summary => 'phpMyAdmin Security Announcement',
        :url => 'http://www.phpmyadmin.net/home_page/security/'
    },
    {
        :abbreviation => 'SECUNIA',
        :obsolete => false,
        :summary => 'Secunia',
        :url => 'https://secunia.com/advisories'
    },
    {
        :abbreviation => 'US-CERT-VU',
        :obsolete => false,
        :summary => 'United States Computer Emergency Readiness Team Vulnerability Notes Database',
        :url => 'http://www.kb.cert.org/vuls'
    },
    {
        :abbreviation => 'waraxe',
        :obsolete => false,
        :summary => 'Waraxe Advisories',
        :url => 'http://www.waraxe.us/content-cat-1.html'
    }
]
authority_attributes.each do |attributes|
  abbreviation = attributes.fetch(:abbreviation)

  # abbreviation is the only unique and :null => false column, so use it to look for updates.  Authority may be updated
  # if obsolete, summary, or url are currently nil, but attributes has non-nil value as could occur if authority is made
  # from module metadata before a seed exists.
  authority = Mdm::Authority.where(:abbreviation => abbreviation).first_or_initialize

  # can use ||= with boolean column because whoever asserts the authority is obsolete wins
  authority.obsolete ||= attributes.fetch(:obsolete)

  authority.summary ||= attributes.fetch(:summary)
  authority.url ||= attributes.fetch(:url)

  authority.save!
end

Mdm::Module::Rank::NUMBER_BY_NAME.each do |name, number|
  Mdm::Module::Rank.where(:name => name, :number => number).first_or_create!
end