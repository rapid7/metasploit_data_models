# @title Mdm::Module SQL translations

# Purpose

The purpose of this guide is to help developers transistion from the `Mdm::Module::Detail` module cache present in
metasploit_data_models <= 0.16.5 to the `Mdm::Module::Instance` module cache present in metasploit_data_models >= 0.17.2.

# Translations

## Actions

Actions are semantically tied to their module, so two actions with the same name on different modules don't necessarily
do the same thing, so `module_actions` remained unchanged except for its foreign key.

### Listing

#### <= 0.16.5

```sql
SELECT module_actions.name
FROM module_actions
WHERE module_actions.detail_id = ?
```

#### >= 0.17.2

```sql
SELECT module_actions.name
FROM module_actions
WHERE module_actions.module_instance_id = ?
```

### Default

The default action changed from being denormalized on `module_details` in metasploit_data_model <= 0.6.15 to being a
foreign key on `module_instances` in metasploit_data_models >= 0.17.2.

#### <= 0.16.5

```sql
SELECT module_details.default_action
FROM module_details
WHERE module_details.id = ?
```

#### >= 0.17.2

```sql
SELECT module_actions.name
FROM module_actions
JOIN module_instances
ON module_instances.default_action_id = module_actions.id
WHERE module_instances.id = ?
```

## Archs (<= 0.16.5) / Architectures (>= 0.17.2)

In metasploit_data_model >= 0.17.2, Architectures became independent entities so that they could be seeded and shared
between Hosts and Modules.

### <= 0.16.5

```sql
SELECT module_archs.name
FROM module_archs
WHERE module_archs.detail_id = ?
```

### >= 0.17.2

```sql
SELECT architectures.abbreviation
FROM architectures
JOIN module_architectures
ON module_architectures.architecture_id = architecture.id
WHERE module_architectures.module_instance_id = ?
```

## Authors

In metasploit_data_models >= 0.17.2, Authors and Email Addresses became independent entities, separate from their use as
Module Authors.  Therefore, the `module_authors` table was convert to a join table between `authors`, `email_addresses`,
and `module_instances`.

### <= 0.16.5

```sql
SELECT module_authors.name, module_authors.email
FROM module_authors
WHERE module_authors.module_detail_id = ?
```

### >= 0.17.2

```sql
SELECT authors.name,
       (email_addresses.local || '@' || email_addresses.domain)
FROM module_authors
JOIN authors
ON authors.id = module_authors.author_id
LEFT OUTER JOIN email_addresses
ON email_addresses.id = module_authors.email_address_id
WHERE module_authors.module_instance_id = ?
```

## description

Description is the similar in both versions.

### <= 0.16.5

```sql
SELECT module_details.description
FROM module_details
WHERE module_details.id = ?
```

### >= 0.17.2

```sql
SELECT module_instances.description
FROM module_instances
WHERE module_instances.id = ?
```

## disclosure_date (<= 0.16.5) / disclosed_on (>= 0.17.2)

In metasploit_data_models <= 0.16.5, `module_details.disclosure_date` was a datetime column, but was semantically
treated as a date, so there was always a time that had to be ignored, but that could also mess up when converting
between time zones.  In metasploit_data_models >= 0.17.2, `module_instances.disclosed_on` is a true date column and has
had its name changed to reflect the Rails convention for date columns.

### <= 0.16.5

```sql
SELECT module_details.disclosure_date
FROM module_details
WHERE module_details.id = ?
```

### >= 0.17.2

```sql
SELECT module_instances.disclosed_on
FROM module_instances
WHERE module_instances.id = ?
```

## file (<= 0.16.5) / real_path (>= 0.17.2)

metasploit_data_models >= 0.17.2 adds a more granular tracking of the files that make up an instantiated module.  Due to
payload modules being composed of potentially a stage and stager file, the file/real_path is no longer attached
to `module_instances` (the equivalent of `module_details` in metasploit_data_models <= 0.16.5).  The files making up a
module are tracked in `module_ancestors`, which can be reached from `module_instances` by way of `module_classes` and
the join table `module_relationships`.  As implied by the name, `real_path` is also guarenteed to be real (absolute)
path, so it is free of any symlinks and is not relative, unlike `file`.

### <= 0.16.5

```sql
SELECT module_details.file
FROM module_details
WHERE module_details.id = ?
```

### >= 0.17.2

```sql
-- this will return multiple rows for staged payloaded
SELECT module_ancestors.real_path
FROM module_ancestors
JOIN module_relationships
ON module_relationships.ancestor_id = module_ancestors.id
JOIN module_classes
ON module_classes.id = module_relationships.descendant_id
JOIN module_instances
ON module_instances.module_class_id = module_classes.id
WHERE module_instances.id = ?
```

## fullname (<= 0.16.5) / full_name (>= 0.17.2)

The full name is just the concatentation of the module type (mtype or module_type) with the reference name (refname or
reference_name), so it is better to just search on those individual fields than to search by full name.  The full name
is only provided for easier display so that it does not need to be derived from the module type and reference name in
reports.

## license

License is the similar in both versions.

### <= 0.16.5

```sql
SELECT module_details.license
FROM module_details
WHERE module_details.id = ?
```

### >= 0.17.2

```sql
SELECT module_instances.license
FROM module_instances
WHERE module_instances.id = ?
```

## mtime (<= 0.16.5) / modification_time (>= 0.17.2)

metasploit_data_models >= 0.17.2 adds a more granular tracking of the files that make up an instantiated module.  Due to
payload modules being composed of potentially a stage and stager file, the mtime/modification_time is no longer attached
to `module_instances` (the equivalent of `module_details` in metasploit_data_models <= 0.16.5).  The files making up a
module are tracked in `module_ancestors`, which can be reached from `module_instances` by way of `module_classes` and
the join table `module_relationships`.

### <= 0.16.5

```sql
SELECT module_details.mtime
FROM module_details
WHERE module_details.id = ?
```

### >= 0.17.2

```sql
-- this will return multiple rows for staged payloaded
SELECT module_ancestors.real_path_modified_at
FROM module_ancestors
JOIN module_relationships
ON module_relationships.ancestor_id = module_ancestors.id
JOIN module_classes
ON module_classes.id = module_relationships.descendant_id
JOIN module_instances
ON module_instances.module_class_id = module_classes.id
WHERE module_instances.id = ?
```

## mtype (<= 0.16.5) / module_type (>= 0.17.2)

In metasploit_data_models >= 0.17.2, the `module_type` is stored in `module_classes` as it can be derived from
`module_ancestors.module_type` without having to instantiate the module and creating a `module_instances` row.

### <= 0.16.5

```sql
SELECT module_details.mtype
FROM module_details
WHERE module_details.id = ?
```

### >= 0.17.2

```sql
SELECT module_classes.module_type
FROM module_classes
JOIN module_instances
ON module_instances.module_class_id = module_classes.id
WHERE module_instances.id = ?
```

## name

The name of a module is only set in `#intialize`, so it is attached to `module_instances` instead of `module_classes` in
metasploit_data_models >= 0.17.2

### <= 0.16.5

```sql
SELECT module_details.name
FROM module_details
WHERE module_details.id = ?
```

### >= 0.17.2

```sql
SELECT module_instances.name
FROM module_instances
WHERE module_instances.id = ?
```

## Platforms

In metasploit_data_models >= 0.17.2, Platforms became independent entities from their use with Modules.
`module_platforms` is now a join table between `module_instances` and `platforms`.

### <= 0.16.5

```sql
SELECT module_platforms.name
FROM module_platforms
WHERE module_platforms.detail_id = ?
```

### >= 0.17.2

```sql
SELECT platforms.name
FROM platforms
JOIN module_platforms
ON module_platforms.platform_id = platform.id
WHERE module_platforms.module_instance_id = ?
```

## privileged

Privileged is the similar in both versions.

### <= 0.16.5

```sql
SELECT module_details.privileged
FROM module_details
WHERE module_details.id = ?
```

### >= 0.17.2

```sql
SELECT module_instances.privileged
FROM module_instances
WHERE module_instances.id = ?
```

## rank

In metasploit_data_models >= 0.17.2, Rank became an independent entity so that it could be seeded and reflect that there
are only a predefined number of ranks.  Additionally, the rank name is included in addition to the number, so there is
no longer a need to use a `CASE` statement or ` lookup table to convert a numerical rank to the rank constant's name as
there was in metasploit_data_models <= 0.16.5.

### Listing

#### <= 0.16.5

```sql
SELECT module_details.rank
FROM module_details
WHERE module_details.id = ?
```

#### >= 0.17.2

```sql
SELECT module_ranks.number, module_ranks.name
FROM module_ranks
JOIN module_classes
ON module_classes.rank_id = rank.id
JOIN module_instances
ON module_instances.module_class_id = module_classes.id
WHERE module_instance.id = ?
```

### Ordering

In general, modules are usually ordered from Excellent to Manual, which correspond to greatest number to lowest number,
so descending ordering is used.

#### <= 0.16.5

```sql
SELECT module_details.rank, module_details.id
FROM module_details
ORDER BY module_details.rank DESC
```

#### >= 0.17.5

```sql
SELECT module_ranks.name, module_instances.id
FROM module_instances
JOIN module_classes
ON module_classes.id = module_instance.module_class_id
JOIN module_ranks
ON module_ranks.id = module_classes.rank_id
ORDER BY module_ranks.number DESC
```

## ready

There is no concept of ready in metasploit_data_models >= 0.17.2 as `module_details.ready` was an odd column in
metasploit_data_models <= 0.16.5 that was toggled to indicate if the associations for `module_details` row were
complete, but this is properly handled using transactions now.

## References

References, including Module and Vuln References went through an major overhaul, so that in metasploit_data_model >= 0.17.2,
`module_references` and `vuln_reference` are just join tables to a shared `references` table.  In addition,
the new `references` table contains more than the old `name` column: a Reference has an authority, such as CVE,
a designation, assigned by that authority, and or a derived URL.  Due to these differences, the results of the below
queries will be dissimilar as >= 0.17.2 has more granular data.

### Module References

#### <= 0.16.5

```sql
SELECT module_refs.name -- either 'CVE-1234' or 'URL-http://example.com'
FROM module_refs
WHERE module_refs.detail_id = ?
```

#### >= 0.17.2

```sql
SELECT authorities.abbreviation, -- may be NULL if only a URL
       references.designation, -- may be NULL if only a URL
       references.url -- may be NULL if authorities.obsolete is true
FROM module_references
JOIN references
ON references.id = module_references.reference_id
LEFT OUTER JOIN authorities
ON authorities.id = references.authority_id
WHERE module_references.module_instance_id = ?
```

### Vuln References

#### <= 0.16.5

```sql
SELECT refs.name -- either 'CVE-1234' or 'URL-http://example.com'
FROM vulns_refs -- note incorrect pluralization of table name
JOIN refs
ON refs.id = vulns_refs.ref_id -- note incorrect pluralization of vuln_ref to vulns_refs instead of vuln_refs
WHERE vulns_refs.vuln_id = ? -- note incorrect pluralization of vuln_ref to vulns_refs instead of vuln_refs
```

#### >= 0.17.2

```sql
SELECT authorities.abbreviation, -- may be NULL if only a URL
       references.designation, -- may be NULL if only a URL
       references.url -- may be NULL if authorities.obsolete is true
FROM vuln_references
JOIN references
ON references.id = vuln_references.reference_id
LEFT OUTER JOIN authories
ON authorities.id = references.authority_id
WHERE vuln_references.vuln_id = ?
```

### Vulns with same Reference as Module

#### <= 0.16.5

```sql
SELECT DISTINCT vulns.id
FROM vulns
JOIN vulns_refs -- note incorrect pluralization of vuln_ref to vulns_refs instead of vuln_refs
ON vulns_refs.vuln_id = vulns.id
JOIN refs
ON refs.id = vulns_refs.ref_id  -- note incorrect pluralization of vuln_ref to vulns_refs instead of vuln_refs
JOIN module_refs
ON module_refs.name = refs.name -- note the odd join by a non-foreign-key
WHERE module_refs.detail_id = ?
```

#### >= 0.17.2

```sql
SELECT DISTINCT vulns.id
FROM vulns
JOIN vuln_references
ON vuln_references.vuln_id = vulns.id
-- can optimize out join through references.id by using foreign key, reference_id
JOIN module_references
ON module_references.reference_id = vuln_references.references.id
WHERE module_references.module_instance_id = ?
```

## refname (<= 0.16.5) / reference_name (>= 0.17.2)

In metasploit_data_models >= 0.17.2, a distinction is made between the reference name of load files
(`module_ancestors.reference_name`) and the reference name of the modules composed of those files
(`module_classes.reference_name`) as staged payload have a name derives from both files and the handler type.

### From ID

#### <= 0.16.5

```sql
SELECT module_details.refname
FROM module_details
WHERE module_details.id = ?
```

#### >= 0.17.2

```sql
SELECT module_classes.reference_name
FROM module_classes
JOIN module_instances
ON module_instances.module_class_id = module_classes.id
WHERE module_instances.id = ?
```

### To ID

#### <= 0.16.5

```sql
SELECT module_details.id
FROM module_details
WHERE module_details.refname = ?
```

#### >= 0.17.2

```sql
SELECT module_instances.id
FROM module_instances
JOIN module_classes
ON module_classes.id = module_instances.module_class_id
WHERE module_classes.reference_name = ?
```

## stance

Stance is the similar in both versions.

### <= 0.16.5

```sql
SELECT module_details.stance
FROM module_details
WHERE module_details.id = ?
```

### >= 0.17.2

```sql
SELECT module_instances.stance
FROM module_instances
WHERE module_instances.id = ?
```

## Targets

The `module_targets` did not change between version except for foreign key changing from `detail_id` to
`module_instance_id`.

### Listing

#### <= 0.16.5

```sql
SELECT module_targets.index, module_targets.name
FROM module_targets
WHERE module_targets.detail_id = ?
ORDER BY module_targets.index ASC
```

#### >= 0.17.2

```sql
SELECT module_targets.index, module_targets.name
FROM module_targets
WHERE module_targets.module_instance_id = ?
ORDER BY module_targets.index ASC
```

### Default

The default target for a module changed from a denormalized index on `module_details` in metasploit_data_models
<= 0.16.5 to a foreign key on `module_instances` in metasploit_data_models >= 0.17.2.

#### <= 0.16.5

```sql
SELECT module_targets.index, module_targets.name
FROM module_targets
JOIN module_details
ON module_details.id = module_targets.detail_id AND
   module_details.default_target = module_targets.index
WHERE module_details.id = ?
```

#### >= 0.17.2

```sql
SELECT module_targets.index, module_targets.name
FROM module_targets
JOIN module_instances
ON module_instances.id = module_targets.module_instance_id AND
   module_instances.default_target_id = module_targets.id
WHERE module_instances.id = ?
```