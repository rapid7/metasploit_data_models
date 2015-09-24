shared_context "::Nexpose::Data::ImportObjectGraphs" do
  let(:workspace){ FactoryGirl.create(:mdm_workspace)}
  let(:user){ FactoryGirl.create(:mdm_user)}

  #
  # Nexpose constructs
  #
  let(:import_run){ FactoryGirl.create(:nexpose_data_import_run, user: user, workspace:workspace)}
  let(:site){ FactoryGirl.create(:nexpose_data_site, import_run: import_run, name: "Test Net")}
  let!(:asset){  FactoryGirl.create(:nexpose_data_asset, sites: [site])  }
  let(:vulnerability_definition){ FactoryGirl.create(:nexpose_data_vulnerability_definition) }

  #
  # Metasploit constructs
  #
  let(:exploit_module_fullname){ "exploit/windows/#{Faker::Lorem.characters(8)}/#{Faker::Lorem.characters(8)}" }
  let(:aux_module_fullname){ "auxiliary/windows/#{Faker::Lorem.characters(8)}/#{Faker::Lorem.characters(8)}" }
  let(:mdm_module_detail_exploit_aggressive){ FactoryGirl.create(:mdm_module_detail, fullname: exploit_module_fullname, stance: "aggressive") }

  # Aggressive exploit module - "Good" ranking
  let(:mdm_module_detail_exploit_aggressive_good) do
    FactoryGirl.create(:mdm_module_detail,
                       fullname: exploit_module_fullname,
                       rank: 400,
                       stance: "aggressive")
  end

  # Aggressive exploit module - "Great" ranking
  let(:mdm_module_detail_exploit_aggressive_great) do
    FactoryGirl.create(:mdm_module_detail,
                       fullname: exploit_module_fullname,
                       rank: 500,
                       stance: "aggressive")
  end

  # Aggressive exploit module - "Excellent" ranking
  let(:mdm_module_detail_exploit_aggressive_excellent) do
    FactoryGirl.create(:mdm_module_detail,
                       fullname: exploit_module_fullname,
                       rank: 600,
                       stance: "aggressive")
  end

  let(:mdm_module_detail_exploit_passive){ FactoryGirl.create(:mdm_module_detail, fullname: exploit_module_fullname, stance: "passive") }
  let(:mdm_module_detail_aux){ FactoryGirl.create(:mdm_module_detail, fullname: aux_module_fullname, stance: "passive") }

  #
  # Make an ::Nexpose::Data::Exploit with whatever data you need
  #
  def create_nexpose_exploit(module_detail, source_key)
    FactoryGirl.create(:nexpose_data_exploit,
                       source: ::Nexpose::Data::Exploit::METASPLOIT_SOURCE_IDENTIFIER,
                       module_detail: module_detail,
                       source_key: source_key)

  end

  #
  # Make the vulns and definitions and exploits for the asset, etc
  #
  def create_vulnerability_graph(args={})
    asset    = args.fetch(:asset)
    vuln_def = args.fetch(:vuln_def)
    exploit  = args.fetch(:exploit)

    vuln_def.exploits << exploit
    nx_vuln = FactoryGirl.create(:nexpose_data_vulnerability, vulnerability_definition: vuln_def)
    FactoryGirl.create(:nexpose_data_vulnerability_instance,
                       asset:asset,
                       vulnerability:nx_vuln,
                       asset_ip_address: asset.ip_addresses.first.address)
  end

  #
  # Create all the Mdm::* models.  Run this AFTER calling create_vulnerability_graph or your data will be fuct
  #
  def coerce_all_site_assets(site)
    site.assets.map(&:to_mdm_hosts)
    site.assets.map(&:create_services_and_vulns_for_mdm_hosts)
  end

end