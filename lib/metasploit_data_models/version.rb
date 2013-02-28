module MetasploitDataModels
  # MetasploitDataModels follows the {http://semver.org/  Semantic Versioning Specification}.  At this time, the API
  # is considered unstable because the database migrations are still in metasploit-framework (the ones in db/migrate are
  # only used for specs at this time)and certain models may not be shared between metasploit-framework and pro, so
  # models may be removed in the future.  Because of the unstable API the version should remain below 1.0.0
  VERSION = '0.5.0'
end
