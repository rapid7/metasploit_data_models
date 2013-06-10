# Namespace for all models dealing with module caching.
#
# Metasploit module metadata is split between 3 classes:
# 1. {Mdm::Module::Load} which represents the ruby Module (in the case of payloads) or ruby Class (in the case
#    of non-paylods) loaded by Msf::Modules::Loader::Base#load_modules and so has file related metadata.
# 2. {Mdm::Module::Class} which represents the Class<Msf::Module> derived from one or more {Mdm::Module::Load loads}.
#    {Mdm::Module::Class} can have a different reference name in the case of payloads.
# 3. {Mdm::Module::Instance} which represents the instance of Msf::Module created from a {Mdm::Module::Class}.  Metadata
#    that is only available after running #initialize is stored in this model.
module Mdm::Module

end