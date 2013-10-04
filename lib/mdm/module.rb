# Namespace for all models dealing with module caching.
#
# Metasploit module metadata is split between 3 classes:
#
# 1. {Mdm::Module::Ancestor} which represents the ruby Module (in the case of payloads) or ruby Class (in the case
#    of non-paylods) loaded by Msf::Modules::Loader::Base#load_modules and so has file related metadata.
# 2. {Mdm::Module::Class} which represents the Class<Msf::Module> derived from one or more
#    {Mdm::Module::Ancestor ancestors}. {Mdm::Module::Class} can have a different reference name in the case of
#    payloads.
# 3. {Mdm::Module::Instance} which represents the instance of Msf::Module created from a {Mdm::Module::Class}.  Metadata
#    that is only available after running #initialize is stored in this model.
#
# # Translation from metasploit_data_models <= 0.16.5
#
# If you're trying to convert your SQL queries from metasploit_data_models <= 0.16.5 and the Mdm::Module::Details cache
# to the new Mdm::Module::Instance cache available in metasploit_data_models >= 0.17.2, then see this
# {file:docs/mdm_module_sql_translation.md guide}.
#
# Entity-Relationship Diagram
# ===========================
# The below Entity-Relationship Diagram (ERD) shows all direct relationships between the models in the Mdm::Module
# namespace.
# All columns are included for ease-of-use with manually written SQL.
#
# ![Mdm::Module (Direct) Entity-Relationship Diagram](../images/mdm-module.erd.png)
module Mdm::Module

end