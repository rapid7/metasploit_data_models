FactoryGirl.define do
  factory :mdm_reference, :class => Mdm::Reference do
    #
    # Associations
    #

    association :authority, :factory => :mdm_authority

    #
    # Attributes
    #

    designation { generate :mdm_reference_designation }
    url { generate :mdm_reference_url }

    factory :obsolete_mdm_reference do
      association :authority, :factory => :obsolete_mdm_authority
      url nil
    end

    factory :url_mdm_reference do
      authority nil
      designation nil
    end
  end

  #
  #
  # Mdm::Reference#designation sequences
  #
  #

  sequence :mdm_reference_designation do |n|
    n.to_s
  end

  #
  # Mdm::Authority-specific Mdm::Reference#designation sequences
  #

  sequence :mdm_reference_bid_designation do |n|
    n.to_s
  end

  sequence :mdm_reference_cve_designation do |n|
    number = n % 10000
    year = n / 10000

    "%04d-%04d" % [year, number]
  end

  sequence :mdm_reference_msb_designation do |n|
    number = n % 1000
    year = n / 1000

    "MS%02d-%03d" % [year, number]
  end

  sequence :mdm_reference_osvdb_designation do |n|
    n.to_s
  end

  sequence :mdm_reference_pmasa_designation do |n|
    number = n / 100
    year = n / 100

    "#{year}-#{number}"
  end

  sequence :mdm_reference_secunia_designation do |n|
    n.to_s
  end

  sequence :mdm_reference_us_cert_vu_designation do |n|
    n.to_s
  end

  sequence :mdm_reference_waraxe_designation do |n|
    # numbers don't rollover on the year like other authorities
    year = n
    number = n

    "%d-SA#%d" % [year, number]
  end

  sequence :mdm_reference_url do |n|
    "http://example.com/mdm/reference/#{n}"
  end
end