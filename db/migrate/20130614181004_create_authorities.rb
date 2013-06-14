# Create authorities
class CreateAuthorities < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Attributes for seeds
  ATTRIBUTES = [
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

  # Table being created
  TABLE_NAME = :authorities

  def down
    drop_table TABLE_NAME
  end

  def up
    # columns
    create_table TABLE_NAME do |t|
      t.string :abbreviation, :null => false
      t.boolean :obsolete, :default => false, :null => false
      t.string :summary, :null => true
      t.text :url, :null => true
    end

    # indices
    change_table TABLE_NAME do |t|
      t.index :abbreviation, :unique => true
      t.index :summary, :unique => true
      t.index :url, :unique => true
    end

    # seeds
  end
end
