--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: collapse_ranges(integer[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION collapse_ranges(all_results integer[]) RETURNS text
    LANGUAGE plpgsql STRICT
    AS $$
          DECLARE
            x int;
            last_member int;
            current_range int[];
            final_string text;
            result_size int := array_upper(all_results, 1);
            iter int := 0;
          BEGIN
            FOREACH x IN ARRAY all_results 
            LOOP
            
              if current_range is null then
                current_range := array_append(current_range, x);
              else 
                if (x = last_member + 1) then -- if it is the increment of the previous, add to range
                  current_range := array_append(current_range, x);
                else -- next element is non-consecutive
                  if array_upper(current_range,1) > 1 then -- if the previous element ended a range, add it 
                    final_string := concat(final_string, current_range[array_lower(current_range, 1)], ' - ', current_range[array_upper(current_range, 1)]);
                  else
                    final_string := concat(final_string, current_range[array_upper(current_range, 1)]);
                  end if;
                  final_string := concat(final_string, ', ');
                  current_range := '{}';
                  current_range := array_append(current_range, x);
                end if;
              end if;
              last_member := x;
              iter := iter + 1;
              if iter = result_size then -- last entry
                if array_upper(current_range,1) > 1 then -- if the previous element ended a range, add it 
                  final_string := concat(final_string, current_range[array_lower(current_range, 1)], ' - ', current_range[array_upper(current_range, 1)]);
                else
                  final_string := concat(final_string, x);
                end if;
              end if;

            END LOOP;
            return final_string;
          END;
        $$;


--
-- Name: wrap_string(character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION wrap_string(orig_text character varying, max_chunk_length integer DEFAULT 50) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    wrapped_array     VARCHAR[] := '{}';
    wrapped_string    VARCHAR;
    orig_length       INTEGER;
    chunk             VARCHAR;
    iIndex            INTEGER;
    iPos              INTEGER;
BEGIN
  -- max_chunk_length: Max width of each line before wrap
  orig_length := LENGTH(orig_text);

  IF (orig_length <= max_chunk_length) THEN
    -- The string can be returned as-is
    wrapped_string := orig_text;
  ELSE
    -- The string needs to be sliced into chunks of lengths of max_chunk_length
    iPos := 1;
    iIndex := 0;
    WHILE iPos <= orig_length LOOP
      iIndex := iIndex + 1;
      chunk := substring(orig_text, iPos, max_chunk_length);
      -- Each chunk is added into an array
      wrapped_array := array_append(wrapped_array, chunk);
      iPos := iPos + max_chunk_length;
    END LOOP;
      -- Combine array into final wrapped string
      -- Line break is used in JasperReport field with HTML styling
      -- to enforce width:
      wrapped_string := array_to_string(wrapped_array, '<br>');
  END IF;

  RETURN wrapped_string;
END $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE api_keys (
    id integer NOT NULL,
    token text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying(255)
);


--
-- Name: api_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE api_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE api_keys_id_seq OWNED BY api_keys.id;


--
-- Name: app_categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE app_categories (
    id integer NOT NULL,
    name character varying(255)
);


--
-- Name: app_categories_apps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE app_categories_apps (
    id integer NOT NULL,
    app_id integer,
    app_category_id integer,
    name character varying(255)
);


--
-- Name: app_categories_apps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE app_categories_apps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: app_categories_apps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE app_categories_apps_id_seq OWNED BY app_categories_apps.id;


--
-- Name: app_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE app_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: app_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE app_categories_id_seq OWNED BY app_categories.id;


--
-- Name: app_runs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE app_runs (
    id integer NOT NULL,
    started_at timestamp without time zone,
    stopped_at timestamp without time zone,
    app_id integer,
    config text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state character varying(255),
    workspace_id integer,
    hidden boolean DEFAULT false
);


--
-- Name: app_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE app_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: app_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE app_runs_id_seq OWNED BY app_runs.id;


--
-- Name: apps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE apps (
    id integer NOT NULL,
    name character varying(255),
    description text,
    rating double precision,
    symbol character varying(255),
    hidden boolean DEFAULT false
);


--
-- Name: apps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE apps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE apps_id_seq OWNED BY apps.id;


--
-- Name: automatic_exploitation_match_results; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE automatic_exploitation_match_results (
    id integer NOT NULL,
    match_id integer,
    run_id integer,
    state character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: automatic_exploitation_match_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE automatic_exploitation_match_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: automatic_exploitation_match_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE automatic_exploitation_match_results_id_seq OWNED BY automatic_exploitation_match_results.id;


--
-- Name: automatic_exploitation_match_sets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE automatic_exploitation_match_sets (
    id integer NOT NULL,
    workspace_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: automatic_exploitation_match_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE automatic_exploitation_match_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: automatic_exploitation_match_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE automatic_exploitation_match_sets_id_seq OWNED BY automatic_exploitation_match_sets.id;


--
-- Name: automatic_exploitation_matches; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE automatic_exploitation_matches (
    id integer NOT NULL,
    vuln_id integer,
    module_detail_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    match_set_id integer,
    nexpose_data_exploit_id integer,
    matchable_type character varying(255),
    matchable_id integer
);


--
-- Name: automatic_exploitation_matches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE automatic_exploitation_matches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: automatic_exploitation_matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE automatic_exploitation_matches_id_seq OWNED BY automatic_exploitation_matches.id;


--
-- Name: automatic_exploitation_runs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE automatic_exploitation_runs (
    id integer NOT NULL,
    workspace_id integer,
    user_id integer,
    match_set_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state character varying(255)
);


--
-- Name: automatic_exploitation_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE automatic_exploitation_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: automatic_exploitation_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE automatic_exploitation_runs_id_seq OWNED BY automatic_exploitation_runs.id;


--
-- Name: brute_force_guess_attempts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE brute_force_guess_attempts (
    id integer NOT NULL,
    brute_force_run_id integer NOT NULL,
    brute_force_guess_core_id integer NOT NULL,
    service_id integer NOT NULL,
    attempted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status character varying(255) DEFAULT 'Untried'::character varying,
    session_id integer,
    login_id integer
);


--
-- Name: brute_force_guess_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE brute_force_guess_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brute_force_guess_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE brute_force_guess_attempts_id_seq OWNED BY brute_force_guess_attempts.id;


--
-- Name: brute_force_guess_cores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE brute_force_guess_cores (
    id integer NOT NULL,
    private_id integer,
    public_id integer,
    realm_id integer,
    workspace_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: brute_force_guess_cores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE brute_force_guess_cores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brute_force_guess_cores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE brute_force_guess_cores_id_seq OWNED BY brute_force_guess_cores.id;


--
-- Name: brute_force_reuse_attempts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE brute_force_reuse_attempts (
    id integer NOT NULL,
    brute_force_run_id integer NOT NULL,
    metasploit_credential_core_id integer NOT NULL,
    service_id integer NOT NULL,
    attempted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status character varying(255) DEFAULT 'Untried'::character varying
);


--
-- Name: brute_force_reuse_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE brute_force_reuse_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brute_force_reuse_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE brute_force_reuse_attempts_id_seq OWNED BY brute_force_reuse_attempts.id;


--
-- Name: brute_force_reuse_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE brute_force_reuse_groups (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    workspace_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: brute_force_reuse_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE brute_force_reuse_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brute_force_reuse_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE brute_force_reuse_groups_id_seq OWNED BY brute_force_reuse_groups.id;


--
-- Name: brute_force_reuse_groups_metasploit_credential_cores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE brute_force_reuse_groups_metasploit_credential_cores (
    brute_force_reuse_group_id integer NOT NULL,
    metasploit_credential_core_id integer NOT NULL
);


--
-- Name: brute_force_runs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE brute_force_runs (
    id integer NOT NULL,
    config text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    task_id integer
);


--
-- Name: brute_force_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE brute_force_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brute_force_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE brute_force_runs_id_seq OWNED BY brute_force_runs.id;


--
-- Name: clients; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE clients (
    id integer NOT NULL,
    host_id integer,
    created_at timestamp without time zone,
    ua_string character varying(1024) NOT NULL,
    ua_name character varying(64),
    ua_ver character varying(32),
    updated_at timestamp without time zone
);


--
-- Name: clients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE clients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE clients_id_seq OWNED BY clients.id;


--
-- Name: cred_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cred_files (
    id integer NOT NULL,
    workspace_id integer DEFAULT 1 NOT NULL,
    path character varying(1024),
    ftype character varying(16),
    created_by character varying(255),
    name character varying(512),
    "desc" character varying(1024),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cred_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cred_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cred_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cred_files_id_seq OWNED BY cred_files.id;


--
-- Name: credential_cores_tasks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE credential_cores_tasks (
    core_id integer,
    task_id integer
);


--
-- Name: credential_logins_tasks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE credential_logins_tasks (
    login_id integer,
    task_id integer
);


--
-- Name: creds; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE creds (
    id integer NOT NULL,
    service_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "user" character varying(2048),
    pass character varying(4096),
    active boolean DEFAULT true,
    proof character varying(4096),
    ptype character varying(256),
    source_id integer,
    source_type character varying(255)
);


--
-- Name: creds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE creds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: creds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE creds_id_seq OWNED BY creds.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    queue character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: egadz_result_ranges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE egadz_result_ranges (
    id integer NOT NULL,
    task_id integer,
    target_host character varying(255),
    start_port integer,
    end_port integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state character varying(255)
);


--
-- Name: egadz_result_ranges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE egadz_result_ranges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: egadz_result_ranges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE egadz_result_ranges_id_seq OWNED BY egadz_result_ranges.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    workspace_id integer,
    host_id integer,
    created_at timestamp without time zone,
    name character varying(255),
    updated_at timestamp without time zone,
    critical boolean,
    seen boolean,
    username character varying(255),
    info text,
    module_rhost text,
    module_name text
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: exploit_attempts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE exploit_attempts (
    id integer NOT NULL,
    host_id integer,
    service_id integer,
    vuln_id integer,
    attempted_at timestamp without time zone,
    exploited boolean,
    fail_reason character varying(255),
    username character varying(255),
    module text,
    session_id integer,
    loot_id integer,
    port integer,
    proto character varying(255),
    fail_detail text
);


--
-- Name: exploit_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE exploit_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exploit_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE exploit_attempts_id_seq OWNED BY exploit_attempts.id;


--
-- Name: exploited_hosts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE exploited_hosts (
    id integer NOT NULL,
    host_id integer NOT NULL,
    service_id integer,
    session_uuid character varying(8),
    name character varying(2048),
    payload character varying(2048),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: exploited_hosts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE exploited_hosts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exploited_hosts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE exploited_hosts_id_seq OWNED BY exploited_hosts.id;


--
-- Name: exports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE exports (
    id integer NOT NULL,
    workspace_id integer NOT NULL,
    created_by character varying(255),
    export_type character varying(255),
    name character varying(255),
    state character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    file_path character varying(1024),
    mask_credentials boolean DEFAULT false,
    completed_at timestamp without time zone,
    included_addresses text,
    excluded_addresses text,
    started_at timestamp without time zone
);


--
-- Name: exports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE exports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE exports_id_seq OWNED BY exports.id;


--
-- Name: generated_payloads; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE generated_payloads (
    id integer NOT NULL,
    state character varying(255),
    file character varying(255),
    options text,
    workspace_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    generator_error character varying(255),
    payload_class character varying(255)
);


--
-- Name: generated_payloads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE generated_payloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: generated_payloads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE generated_payloads_id_seq OWNED BY generated_payloads.id;


--
-- Name: host_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE host_details (
    id integer NOT NULL,
    host_id integer,
    nx_console_id integer,
    nx_device_id integer,
    src character varying(255),
    nx_site_name character varying(255),
    nx_site_importance character varying(255),
    nx_scan_template character varying(255),
    nx_risk_score double precision
);


--
-- Name: host_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE host_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: host_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE host_details_id_seq OWNED BY host_details.id;


--
-- Name: hosts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE hosts (
    id integer NOT NULL,
    created_at timestamp without time zone,
    address inet NOT NULL,
    mac character varying(255),
    comm character varying(255),
    name character varying(255),
    state character varying(255),
    os_name character varying(255),
    os_flavor character varying(255),
    os_sp character varying(255),
    os_lang character varying(255),
    arch character varying(255),
    workspace_id integer NOT NULL,
    updated_at timestamp without time zone,
    purpose text,
    info character varying(65536),
    comments text,
    scope text,
    virtual_host text,
    note_count integer DEFAULT 0,
    vuln_count integer DEFAULT 0,
    service_count integer DEFAULT 0,
    host_detail_count integer DEFAULT 0,
    exploit_attempt_count integer DEFAULT 0,
    cred_count integer DEFAULT 0,
    nexpose_data_asset_id integer,
    history_count integer DEFAULT 0,
    detected_arch character varying(255)
);


--
-- Name: hosts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE hosts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hosts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE hosts_id_seq OWNED BY hosts.id;


--
-- Name: hosts_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE hosts_tags (
    host_id integer,
    tag_id integer,
    id integer NOT NULL
);


--
-- Name: hosts_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE hosts_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hosts_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE hosts_tags_id_seq OWNED BY hosts_tags.id;


--
-- Name: known_ports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE known_ports (
    id integer NOT NULL,
    port integer NOT NULL,
    proto character varying(255) DEFAULT 'tcp'::character varying NOT NULL,
    name character varying(255) NOT NULL,
    info text
);


--
-- Name: known_ports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE known_ports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: known_ports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE known_ports_id_seq OWNED BY known_ports.id;


--
-- Name: listeners; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE listeners (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    workspace_id integer DEFAULT 1 NOT NULL,
    task_id integer,
    enabled boolean DEFAULT true,
    owner text,
    payload text,
    address text,
    port integer,
    options bytea,
    macro text
);


--
-- Name: listeners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE listeners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: listeners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE listeners_id_seq OWNED BY listeners.id;


--
-- Name: loots; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE loots (
    id integer NOT NULL,
    workspace_id integer DEFAULT 1 NOT NULL,
    host_id integer,
    service_id integer,
    ltype character varying(512),
    path character varying(1024),
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    content_type character varying(255),
    name text,
    info text
);


--
-- Name: loots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE loots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: loots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE loots_id_seq OWNED BY loots.id;


--
-- Name: macros; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE macros (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    owner text,
    name text,
    description text,
    actions bytea,
    prefs bytea
);


--
-- Name: macros_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE macros_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: macros_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE macros_id_seq OWNED BY macros.id;


--
-- Name: metasploit_credential_core_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE metasploit_credential_core_tags (
    id integer NOT NULL,
    core_id integer NOT NULL,
    tag_id integer NOT NULL
);


--
-- Name: metasploit_credential_core_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE metasploit_credential_core_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metasploit_credential_core_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE metasploit_credential_core_tags_id_seq OWNED BY metasploit_credential_core_tags.id;


--
-- Name: metasploit_credential_cores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE metasploit_credential_cores (
    id integer NOT NULL,
    origin_id integer NOT NULL,
    origin_type character varying(255) NOT NULL,
    private_id integer,
    public_id integer,
    realm_id integer,
    workspace_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    logins_count integer DEFAULT 0
);


--
-- Name: metasploit_credential_cores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE metasploit_credential_cores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metasploit_credential_cores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE metasploit_credential_cores_id_seq OWNED BY metasploit_credential_cores.id;


--
-- Name: metasploit_credential_login_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE metasploit_credential_login_tags (
    id integer NOT NULL,
    login_id integer NOT NULL,
    tag_id integer NOT NULL
);


--
-- Name: metasploit_credential_login_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE metasploit_credential_login_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metasploit_credential_login_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE metasploit_credential_login_tags_id_seq OWNED BY metasploit_credential_login_tags.id;


--
-- Name: metasploit_credential_logins; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE metasploit_credential_logins (
    id integer NOT NULL,
    core_id integer NOT NULL,
    service_id integer NOT NULL,
    access_level character varying(255),
    status character varying(255) NOT NULL,
    last_attempted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: metasploit_credential_logins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE metasploit_credential_logins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metasploit_credential_logins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE metasploit_credential_logins_id_seq OWNED BY metasploit_credential_logins.id;


--
-- Name: metasploit_credential_origin_cracked_passwords; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE metasploit_credential_origin_cracked_passwords (
    id integer NOT NULL,
    metasploit_credential_core_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: metasploit_credential_origin_cracked_passwords_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE metasploit_credential_origin_cracked_passwords_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metasploit_credential_origin_cracked_passwords_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE metasploit_credential_origin_cracked_passwords_id_seq OWNED BY metasploit_credential_origin_cracked_passwords.id;


--
-- Name: metasploit_credential_origin_imports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE metasploit_credential_origin_imports (
    id integer NOT NULL,
    filename text NOT NULL,
    task_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: metasploit_credential_origin_imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE metasploit_credential_origin_imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metasploit_credential_origin_imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE metasploit_credential_origin_imports_id_seq OWNED BY metasploit_credential_origin_imports.id;


--
-- Name: metasploit_credential_origin_manuals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE metasploit_credential_origin_manuals (
    id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: metasploit_credential_origin_manuals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE metasploit_credential_origin_manuals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metasploit_credential_origin_manuals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE metasploit_credential_origin_manuals_id_seq OWNED BY metasploit_credential_origin_manuals.id;


--
-- Name: metasploit_credential_origin_services; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE metasploit_credential_origin_services (
    id integer NOT NULL,
    service_id integer NOT NULL,
    module_full_name text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: metasploit_credential_origin_services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE metasploit_credential_origin_services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metasploit_credential_origin_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE metasploit_credential_origin_services_id_seq OWNED BY metasploit_credential_origin_services.id;


--
-- Name: metasploit_credential_origin_sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE metasploit_credential_origin_sessions (
    id integer NOT NULL,
    post_reference_name text NOT NULL,
    session_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: metasploit_credential_origin_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE metasploit_credential_origin_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metasploit_credential_origin_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE metasploit_credential_origin_sessions_id_seq OWNED BY metasploit_credential_origin_sessions.id;


--
-- Name: metasploit_credential_privates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE metasploit_credential_privates (
    id integer NOT NULL,
    type character varying(255) NOT NULL,
    data text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    jtr_format character varying(255)
);


--
-- Name: metasploit_credential_privates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE metasploit_credential_privates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metasploit_credential_privates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE metasploit_credential_privates_id_seq OWNED BY metasploit_credential_privates.id;


--
-- Name: metasploit_credential_publics; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE metasploit_credential_publics (
    id integer NOT NULL,
    username character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    type character varying(255) NOT NULL
);


--
-- Name: metasploit_credential_publics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE metasploit_credential_publics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metasploit_credential_publics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE metasploit_credential_publics_id_seq OWNED BY metasploit_credential_publics.id;


--
-- Name: metasploit_credential_realms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE metasploit_credential_realms (
    id integer NOT NULL,
    key character varying(255) NOT NULL,
    value character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: metasploit_credential_realms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE metasploit_credential_realms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metasploit_credential_realms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE metasploit_credential_realms_id_seq OWNED BY metasploit_credential_realms.id;


--
-- Name: mm_domino_edges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mm_domino_edges (
    id integer NOT NULL,
    dest_node_id integer NOT NULL,
    login_id integer NOT NULL,
    run_id integer NOT NULL,
    source_node_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: mm_domino_edges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mm_domino_edges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mm_domino_edges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mm_domino_edges_id_seq OWNED BY mm_domino_edges.id;


--
-- Name: mm_domino_nodes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mm_domino_nodes (
    id integer NOT NULL,
    run_id integer NOT NULL,
    host_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    high_value boolean DEFAULT false,
    captured_creds_count integer DEFAULT 0,
    depth integer DEFAULT 0
);


--
-- Name: mm_domino_nodes_cores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mm_domino_nodes_cores (
    id integer NOT NULL,
    node_id integer NOT NULL,
    core_id integer NOT NULL
);


--
-- Name: mm_domino_nodes_cores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mm_domino_nodes_cores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mm_domino_nodes_cores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mm_domino_nodes_cores_id_seq OWNED BY mm_domino_nodes_cores.id;


--
-- Name: mm_domino_nodes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mm_domino_nodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mm_domino_nodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mm_domino_nodes_id_seq OWNED BY mm_domino_nodes.id;


--
-- Name: mod_refs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mod_refs (
    id integer NOT NULL,
    module character varying(1024),
    mtype character varying(128),
    ref text
);


--
-- Name: mod_refs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mod_refs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mod_refs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mod_refs_id_seq OWNED BY mod_refs.id;


--
-- Name: module_actions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE module_actions (
    id integer NOT NULL,
    detail_id integer,
    name text
);


--
-- Name: module_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE module_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: module_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE module_actions_id_seq OWNED BY module_actions.id;


--
-- Name: module_archs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE module_archs (
    id integer NOT NULL,
    detail_id integer,
    name text
);


--
-- Name: module_archs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE module_archs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: module_archs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE module_archs_id_seq OWNED BY module_archs.id;


--
-- Name: module_authors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE module_authors (
    id integer NOT NULL,
    detail_id integer,
    name text,
    email text
);


--
-- Name: module_authors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE module_authors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: module_authors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE module_authors_id_seq OWNED BY module_authors.id;


--
-- Name: module_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE module_details (
    id integer NOT NULL,
    mtime timestamp without time zone,
    file text,
    mtype character varying(255),
    refname text,
    fullname text,
    name text,
    rank integer,
    description text,
    license character varying(255),
    privileged boolean,
    disclosure_date timestamp without time zone,
    default_target integer,
    default_action text,
    stance character varying(255),
    ready boolean
);


--
-- Name: module_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE module_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: module_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE module_details_id_seq OWNED BY module_details.id;


--
-- Name: module_mixins; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE module_mixins (
    id integer NOT NULL,
    detail_id integer,
    name text
);


--
-- Name: module_mixins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE module_mixins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: module_mixins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE module_mixins_id_seq OWNED BY module_mixins.id;


--
-- Name: module_platforms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE module_platforms (
    id integer NOT NULL,
    detail_id integer,
    name text
);


--
-- Name: module_platforms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE module_platforms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: module_platforms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE module_platforms_id_seq OWNED BY module_platforms.id;


--
-- Name: module_refs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE module_refs (
    id integer NOT NULL,
    detail_id integer,
    name text
);


--
-- Name: module_refs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE module_refs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: module_refs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE module_refs_id_seq OWNED BY module_refs.id;


--
-- Name: module_targets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE module_targets (
    id integer NOT NULL,
    detail_id integer,
    index integer,
    name text
);


--
-- Name: module_targets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE module_targets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: module_targets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE module_targets_id_seq OWNED BY module_targets.id;


--
-- Name: nexpose_consoles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nexpose_consoles (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    enabled boolean DEFAULT true,
    owner text,
    address text,
    port integer DEFAULT 3780,
    username text,
    password text,
    status text,
    version text,
    cert text,
    cached_sites bytea,
    name text
);


--
-- Name: nexpose_consoles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nexpose_consoles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nexpose_consoles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nexpose_consoles_id_seq OWNED BY nexpose_consoles.id;


--
-- Name: nexpose_data_assets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nexpose_data_assets (
    id integer NOT NULL,
    nexpose_data_site_id integer NOT NULL,
    asset_id character varying(255) NOT NULL,
    url character varying(255),
    host_names text,
    os_name character varying(255),
    mac_addresses text,
    last_scan_date timestamp without time zone,
    next_scan_date timestamp without time zone,
    last_scan_id character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: nexpose_data_assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nexpose_data_assets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nexpose_data_assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nexpose_data_assets_id_seq OWNED BY nexpose_data_assets.id;


--
-- Name: nexpose_data_exploits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nexpose_data_exploits (
    id integer NOT NULL,
    module_detail_id integer,
    nexpose_exploit_id character varying(255),
    skill_level character varying(255),
    description text,
    source_key character varying(255),
    source character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: nexpose_data_exploits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nexpose_data_exploits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nexpose_data_exploits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nexpose_data_exploits_id_seq OWNED BY nexpose_data_exploits.id;


--
-- Name: nexpose_data_exploits_vulnerability_definitions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nexpose_data_exploits_vulnerability_definitions (
    exploit_id integer,
    vulnerability_definition_id integer
);


--
-- Name: nexpose_data_import_runs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nexpose_data_import_runs (
    id integer NOT NULL,
    user_id integer,
    workspace_id integer,
    state character varying(255),
    nx_console_id integer,
    metasploitable_only boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    import_state character varying(255)
);


--
-- Name: nexpose_data_import_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nexpose_data_import_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nexpose_data_import_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nexpose_data_import_runs_id_seq OWNED BY nexpose_data_import_runs.id;


--
-- Name: nexpose_data_ip_addresses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nexpose_data_ip_addresses (
    id integer NOT NULL,
    nexpose_data_asset_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    address inet
);


--
-- Name: nexpose_data_ip_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nexpose_data_ip_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nexpose_data_ip_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nexpose_data_ip_addresses_id_seq OWNED BY nexpose_data_ip_addresses.id;


--
-- Name: nexpose_data_scan_templates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nexpose_data_scan_templates (
    id integer NOT NULL,
    nx_console_id integer NOT NULL,
    scan_template_id character varying(255) NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: nexpose_data_scan_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nexpose_data_scan_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nexpose_data_scan_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nexpose_data_scan_templates_id_seq OWNED BY nexpose_data_scan_templates.id;


--
-- Name: nexpose_data_sites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nexpose_data_sites (
    id integer NOT NULL,
    nexpose_data_import_run_id integer NOT NULL,
    site_id character varying(255) NOT NULL,
    name character varying(255),
    description text,
    importance character varying(255),
    type character varying(255),
    last_scan_date timestamp without time zone,
    next_scan_date timestamp without time zone,
    last_scan_id character varying(255),
    summary text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: nexpose_data_sites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nexpose_data_sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nexpose_data_sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nexpose_data_sites_id_seq OWNED BY nexpose_data_sites.id;


--
-- Name: nexpose_data_vulnerabilities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nexpose_data_vulnerabilities (
    id integer NOT NULL,
    nexpose_data_vulnerability_definition_id integer NOT NULL,
    vulnerability_id character varying(255) NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: nexpose_data_vulnerabilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nexpose_data_vulnerabilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nexpose_data_vulnerabilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nexpose_data_vulnerabilities_id_seq OWNED BY nexpose_data_vulnerabilities.id;


--
-- Name: nexpose_data_vulnerability_definitions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nexpose_data_vulnerability_definitions (
    id integer NOT NULL,
    vulnerability_definition_id character varying(255),
    title character varying(255),
    description text,
    date_published date,
    severity_score integer,
    serverity character varying(255),
    pci_severity_score character varying(255),
    pci_status character varying(255),
    riskscore numeric,
    cvss_vector character varying(255),
    cvss_access_vector_id character varying(255),
    cvss_access_complexity_id character varying(255),
    cvss_authentication_id character varying(255),
    cvss_confidentiality_impact_id character varying(255),
    cvss_integrity_impact_id character varying(255),
    cvss_availability_impact_id character varying(255),
    cvss_score numeric,
    cvss_exploit_score numeric,
    cvss_impact_score numeric,
    denial_of_service boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: nexpose_data_vulnerability_definitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nexpose_data_vulnerability_definitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nexpose_data_vulnerability_definitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nexpose_data_vulnerability_definitions_id_seq OWNED BY nexpose_data_vulnerability_definitions.id;


--
-- Name: nexpose_data_vulnerability_instances; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nexpose_data_vulnerability_instances (
    id integer NOT NULL,
    vulnerability_id character varying(255),
    asset_id character varying(255),
    nexpose_data_vulnerability_id integer,
    nexpose_data_asset_id integer,
    scan_id character varying(255),
    date date,
    status character varying(255),
    proof text,
    key character varying(255),
    service character varying(255),
    port integer,
    protocol character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    asset_ip_address inet
);


--
-- Name: nexpose_data_vulnerability_instances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nexpose_data_vulnerability_instances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nexpose_data_vulnerability_instances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nexpose_data_vulnerability_instances_id_seq OWNED BY nexpose_data_vulnerability_instances.id;


--
-- Name: nexpose_data_vulnerability_references; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nexpose_data_vulnerability_references (
    id integer NOT NULL,
    nexpose_data_vulnerability_definition_id integer,
    vulnerability_reference_id character varying(255),
    source character varying(255),
    reference character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: nexpose_data_vulnerability_references_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nexpose_data_vulnerability_references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nexpose_data_vulnerability_references_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nexpose_data_vulnerability_references_id_seq OWNED BY nexpose_data_vulnerability_references.id;


--
-- Name: nexpose_result_exceptions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nexpose_result_exceptions (
    id integer NOT NULL,
    user_id integer,
    nx_scope_type character varying(255),
    nx_scope_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    automatic_exploitation_match_result_id integer,
    nexpose_result_export_run_id integer,
    expiration_date timestamp without time zone,
    reason character varying(255),
    comments text,
    approve boolean,
    sent_to_nexpose boolean,
    sent_at timestamp without time zone
);


--
-- Name: nexpose_result_exceptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nexpose_result_exceptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nexpose_result_exceptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nexpose_result_exceptions_id_seq OWNED BY nexpose_result_exceptions.id;


--
-- Name: nexpose_result_export_runs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nexpose_result_export_runs (
    id integer NOT NULL,
    state character varying(255),
    nx_console_id integer,
    user_id integer,
    workspace_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: nexpose_result_export_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nexpose_result_export_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nexpose_result_export_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nexpose_result_export_runs_id_seq OWNED BY nexpose_result_export_runs.id;


--
-- Name: nexpose_result_validations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nexpose_result_validations (
    id integer NOT NULL,
    user_id integer,
    nexpose_data_asset_id integer,
    verified_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    automatic_exploitation_match_result_id integer,
    nexpose_result_export_run_id integer,
    sent_to_nexpose boolean,
    sent_at timestamp without time zone
);


--
-- Name: nexpose_result_validations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nexpose_result_validations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nexpose_result_validations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nexpose_result_validations_id_seq OWNED BY nexpose_result_validations.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notes (
    id integer NOT NULL,
    created_at timestamp without time zone,
    ntype character varying(512),
    workspace_id integer DEFAULT 1 NOT NULL,
    updated_at timestamp without time zone,
    critical boolean,
    seen boolean,
    data text,
    notable_id integer,
    notable_type character varying(255)
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notes_id_seq OWNED BY notes.id;


--
-- Name: notification_messages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notification_messages (
    id integer NOT NULL,
    workspace_id integer,
    task_id integer,
    title character varying(255),
    content text,
    url character varying(255),
    kind character varying(255),
    created_at timestamp without time zone
);


--
-- Name: notification_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notification_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notification_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notification_messages_id_seq OWNED BY notification_messages.id;


--
-- Name: notification_messages_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notification_messages_users (
    id integer NOT NULL,
    user_id integer,
    message_id integer,
    read boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: notification_messages_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notification_messages_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notification_messages_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notification_messages_users_id_seq OWNED BY notification_messages_users.id;


--
-- Name: pnd_pcap_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pnd_pcap_files (
    id integer NOT NULL,
    task_id integer,
    loot_id integer,
    status character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: pnd_pcap_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pnd_pcap_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pnd_pcap_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pnd_pcap_files_id_seq OWNED BY pnd_pcap_files.id;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE profiles (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    active boolean DEFAULT true,
    name text,
    owner text,
    settings bytea
);


--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profiles_id_seq OWNED BY profiles.id;


--
-- Name: refs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE refs (
    id integer NOT NULL,
    ref_id integer,
    created_at timestamp without time zone,
    name character varying(512),
    updated_at timestamp without time zone
);


--
-- Name: refs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE refs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE refs_id_seq OWNED BY refs.id;


--
-- Name: report_artifacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE report_artifacts (
    id integer NOT NULL,
    report_id integer NOT NULL,
    file_path character varying(1024) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    accessed_at timestamp without time zone
);


--
-- Name: report_artifacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE report_artifacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: report_artifacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE report_artifacts_id_seq OWNED BY report_artifacts.id;


--
-- Name: report_custom_resources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE report_custom_resources (
    id integer NOT NULL,
    workspace_id integer NOT NULL,
    created_by character varying(255),
    resource_type character varying(255),
    name character varying(255),
    file_path character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: report_custom_resources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE report_custom_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: report_custom_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE report_custom_resources_id_seq OWNED BY report_custom_resources.id;


--
-- Name: reports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports (
    id integer NOT NULL,
    workspace_id integer NOT NULL,
    created_by character varying(255),
    report_type character varying(255),
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    file_formats character varying(255),
    options text,
    sections character varying(255),
    report_template character varying(255),
    included_addresses text,
    state character varying(255),
    started_at timestamp without time zone,
    completed_at timestamp without time zone,
    excluded_addresses text,
    se_campaign_id integer,
    app_run_id integer,
    order_vulns_by character varying(255),
    usernames_reported text,
    skip_data_check boolean DEFAULT false,
    email_recipients text,
    logo_path text
);


--
-- Name: reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_id_seq OWNED BY reports.id;


--
-- Name: routes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE routes (
    id integer NOT NULL,
    session_id integer,
    subnet character varying(255),
    netmask character varying(255)
);


--
-- Name: routes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE routes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: routes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE routes_id_seq OWNED BY routes.id;


--
-- Name: run_stats; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE run_stats (
    id integer NOT NULL,
    name character varying(255),
    data double precision,
    task_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: run_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE run_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: run_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE run_stats_id_seq OWNED BY run_stats.id;


--
-- Name: scheduled_tasks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scheduled_tasks (
    id integer NOT NULL,
    kind character varying(255),
    last_run_at timestamp without time zone,
    state character varying(255),
    last_run_status character varying(255),
    task_chain_id integer,
    "position" integer,
    config_hash text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    form_hash text,
    report_hash text,
    file_upload character varying(255),
    legacy boolean DEFAULT false
);


--
-- Name: scheduled_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scheduled_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scheduled_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scheduled_tasks_id_seq OWNED BY scheduled_tasks.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: se_campaign_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE se_campaign_files (
    id integer NOT NULL,
    attachable_id integer,
    attachable_type character varying(255),
    attachment character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    content_disposition character varying(255),
    type character varying(255),
    workspace_id integer,
    user_id integer,
    name character varying(255),
    file_size integer
);


--
-- Name: se_campaign_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE se_campaign_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: se_campaign_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE se_campaign_files_id_seq OWNED BY se_campaign_files.id;


--
-- Name: se_campaigns; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE se_campaigns (
    id integer NOT NULL,
    user_id integer,
    workspace_id integer,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state character varying(255) DEFAULT 'unconfigured'::character varying,
    prefs text,
    port integer,
    started_at timestamp without time zone,
    config_type character varying(255),
    started_by_user_id integer,
    notification_enabled boolean,
    notification_email_address character varying(255),
    notification_email_message text,
    notification_email_subject character varying(255),
    last_target_interaction_at timestamp without time zone
);


--
-- Name: se_campaigns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE se_campaigns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: se_campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE se_campaigns_id_seq OWNED BY se_campaigns.id;


--
-- Name: se_email_openings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE se_email_openings (
    id integer NOT NULL,
    email_id integer,
    human_target_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    address inet
);


--
-- Name: se_email_openings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE se_email_openings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: se_email_openings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE se_email_openings_id_seq OWNED BY se_email_openings.id;


--
-- Name: se_email_sends; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE se_email_sends (
    id integer NOT NULL,
    email_id integer,
    human_target_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sent boolean,
    status_message character varying(255)
);


--
-- Name: se_email_sends_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE se_email_sends_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: se_email_sends_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE se_email_sends_id_seq OWNED BY se_email_sends.id;


--
-- Name: se_email_templates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE se_email_templates (
    id integer NOT NULL,
    user_id integer,
    content text,
    name character varying(255),
    workspace_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: se_email_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE se_email_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: se_email_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE se_email_templates_id_seq OWNED BY se_email_templates.id;


--
-- Name: se_emails; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE se_emails (
    id integer NOT NULL,
    user_id integer,
    content text,
    name character varying(255),
    subject character varying(255),
    campaign_id integer,
    template_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    from_address character varying(255),
    from_name character varying(255),
    target_list_id integer,
    email_template_id integer,
    prefs text,
    attack_type character varying(255),
    status character varying(255),
    sent_at timestamp without time zone,
    origin_type character varying(255),
    editor_type character varying(255)
);


--
-- Name: se_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE se_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: se_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE se_emails_id_seq OWNED BY se_emails.id;


--
-- Name: se_human_targets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE se_human_targets (
    id integer NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    email_address character varying(255),
    workspace_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: se_human_targets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE se_human_targets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: se_human_targets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE se_human_targets_id_seq OWNED BY se_human_targets.id;


--
-- Name: se_phishing_results; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE se_phishing_results (
    id integer NOT NULL,
    human_target_id integer,
    web_page_id integer,
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    address inet,
    raw_data text,
    browser_name character varying(255),
    browser_version character varying(255),
    os_name character varying(255),
    os_version character varying(255)
);


--
-- Name: se_phishing_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE se_phishing_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: se_phishing_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE se_phishing_results_id_seq OWNED BY se_phishing_results.id;


--
-- Name: se_portable_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE se_portable_files (
    id integer NOT NULL,
    campaign_id integer,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    prefs text,
    file_name character varying(255),
    exploit_module_path character varying(255),
    dynamic_stagers boolean DEFAULT false
);


--
-- Name: se_portable_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE se_portable_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: se_portable_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE se_portable_files_id_seq OWNED BY se_portable_files.id;


--
-- Name: se_target_list_human_targets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE se_target_list_human_targets (
    id integer NOT NULL,
    target_list_id integer,
    human_target_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: se_target_list_human_targets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE se_target_list_human_targets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: se_target_list_human_targets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE se_target_list_human_targets_id_seq OWNED BY se_target_list_human_targets.id;


--
-- Name: se_target_lists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE se_target_lists (
    id integer NOT NULL,
    name character varying(255),
    file_name character varying(255),
    user_id integer,
    workspace_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: se_target_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE se_target_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: se_target_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE se_target_lists_id_seq OWNED BY se_target_lists.id;


--
-- Name: se_tracking_links; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE se_tracking_links (
    id integer NOT NULL,
    external_destination_url character varying(255),
    email_id integer,
    web_page_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: se_tracking_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE se_tracking_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: se_tracking_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE se_tracking_links_id_seq OWNED BY se_tracking_links.id;


--
-- Name: se_visits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE se_visits (
    id integer NOT NULL,
    human_target_id integer,
    web_page_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    email_id integer,
    address inet
);


--
-- Name: se_visits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE se_visits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: se_visits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE se_visits_id_seq OWNED BY se_visits.id;


--
-- Name: se_web_pages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE se_web_pages (
    id integer NOT NULL,
    campaign_id integer,
    path character varying(255),
    content text,
    clone_url character varying(255),
    online boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying(255),
    prefs text,
    template_id integer,
    attack_type character varying(255),
    origin_type character varying(255),
    phishing_redirect_origin character varying(255)
);


--
-- Name: se_web_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE se_web_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: se_web_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE se_web_pages_id_seq OWNED BY se_web_pages.id;


--
-- Name: se_web_templates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE se_web_templates (
    id integer NOT NULL,
    name character varying(255),
    workspace_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    content text,
    clone_url character varying(255),
    origin_type character varying(255)
);


--
-- Name: se_web_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE se_web_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: se_web_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE se_web_templates_id_seq OWNED BY se_web_templates.id;


--
-- Name: services; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE services (
    id integer NOT NULL,
    host_id integer,
    created_at timestamp without time zone,
    port integer NOT NULL,
    proto character varying(16) NOT NULL,
    state character varying(255),
    name character varying(255),
    updated_at timestamp without time zone,
    info text
);


--
-- Name: services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE services_id_seq OWNED BY services.id;


--
-- Name: session_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE session_events (
    id integer NOT NULL,
    session_id integer,
    etype character varying(255),
    command bytea,
    output bytea,
    remote_path character varying(255),
    local_path character varying(255),
    created_at timestamp without time zone
);


--
-- Name: session_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE session_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: session_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE session_events_id_seq OWNED BY session_events.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sessions (
    id integer NOT NULL,
    host_id integer,
    stype character varying(255),
    via_exploit character varying(255),
    via_payload character varying(255),
    "desc" character varying(255),
    port integer,
    platform character varying(255),
    datastore text,
    opened_at timestamp without time zone NOT NULL,
    closed_at timestamp without time zone,
    close_reason character varying(255),
    local_id integer,
    last_seen timestamp without time zone,
    campaign_id integer
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    user_id integer,
    name character varying(1024),
    "desc" text,
    report_summary boolean DEFAULT false NOT NULL,
    report_detail boolean DEFAULT false NOT NULL,
    critical boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: task_chains; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE task_chains (
    id integer NOT NULL,
    schedule text,
    name character varying(255),
    last_run_at timestamp without time zone,
    next_run_at timestamp without time zone,
    user_id integer,
    workspace_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state character varying(255) DEFAULT 'ready'::character varying,
    clear_workspace_before_run boolean,
    legacy boolean DEFAULT true,
    active_task_id integer,
    schedule_hash text,
    active_scheduled_task_id integer,
    active_report_id integer,
    last_run_task_id integer,
    last_run_report_id integer
);


--
-- Name: task_chains_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE task_chains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_chains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE task_chains_id_seq OWNED BY task_chains.id;


--
-- Name: task_creds; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE task_creds (
    id integer NOT NULL,
    task_id integer NOT NULL,
    cred_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: task_creds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE task_creds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_creds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE task_creds_id_seq OWNED BY task_creds.id;


--
-- Name: task_hosts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE task_hosts (
    id integer NOT NULL,
    task_id integer NOT NULL,
    host_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: task_hosts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE task_hosts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_hosts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE task_hosts_id_seq OWNED BY task_hosts.id;


--
-- Name: task_services; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE task_services (
    id integer NOT NULL,
    task_id integer NOT NULL,
    service_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: task_services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE task_services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE task_services_id_seq OWNED BY task_services.id;


--
-- Name: task_sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE task_sessions (
    id integer NOT NULL,
    task_id integer NOT NULL,
    session_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: task_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE task_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE task_sessions_id_seq OWNED BY task_sessions.id;


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tasks (
    id integer NOT NULL,
    workspace_id integer DEFAULT 1 NOT NULL,
    created_by character varying(255),
    module character varying(255),
    completed_at timestamp without time zone,
    path character varying(1024),
    info character varying(255),
    description character varying(255),
    progress integer,
    options text,
    error text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    result text,
    module_uuid character varying(8),
    settings bytea,
    app_run_id integer,
    presenter character varying(255),
    state character varying(255) DEFAULT 'unstarted'::character varying
);


--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tasks_id_seq OWNED BY tasks.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    username character varying(255),
    crypted_password character varying(255),
    password_salt character varying(255),
    persistence_token character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    fullname character varying(255),
    email character varying(255),
    phone character varying(255),
    company character varying(255),
    prefs character varying(524288),
    admin boolean DEFAULT true NOT NULL,
    notification_center_count integer DEFAULT 0,
    last_request_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: vuln_attempts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vuln_attempts (
    id integer NOT NULL,
    vuln_id integer,
    attempted_at timestamp without time zone,
    exploited boolean,
    fail_reason character varying(255),
    username character varying(255),
    module text,
    session_id integer,
    loot_id integer,
    fail_detail text
);


--
-- Name: vuln_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vuln_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vuln_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vuln_attempts_id_seq OWNED BY vuln_attempts.id;


--
-- Name: vuln_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vuln_details (
    id integer NOT NULL,
    vuln_id integer,
    cvss_score double precision,
    cvss_vector character varying(255),
    title character varying(255),
    description text,
    solution text,
    proof bytea,
    nx_console_id integer,
    nx_device_id integer,
    nx_vuln_id character varying(255),
    nx_severity double precision,
    nx_pci_severity double precision,
    nx_published timestamp without time zone,
    nx_added timestamp without time zone,
    nx_modified timestamp without time zone,
    nx_tags text,
    nx_vuln_status text,
    nx_proof_key text,
    src character varying(255),
    nx_scan_id integer,
    nx_vulnerable_since timestamp without time zone,
    nx_pci_compliance_status character varying(255)
);


--
-- Name: vuln_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vuln_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vuln_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vuln_details_id_seq OWNED BY vuln_details.id;


--
-- Name: vulns; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vulns (
    id integer NOT NULL,
    host_id integer,
    service_id integer,
    created_at timestamp without time zone,
    name character varying(255),
    updated_at timestamp without time zone,
    info character varying(65536),
    exploited_at timestamp without time zone,
    vuln_detail_count integer DEFAULT 0,
    vuln_attempt_count integer DEFAULT 0,
    nexpose_data_vuln_def_id integer
);


--
-- Name: vulns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vulns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vulns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vulns_id_seq OWNED BY vulns.id;


--
-- Name: vulns_refs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vulns_refs (
    ref_id integer,
    vuln_id integer,
    id integer NOT NULL
);


--
-- Name: vulns_refs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vulns_refs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vulns_refs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vulns_refs_id_seq OWNED BY vulns_refs.id;


--
-- Name: web_attack_cross_site_scriptings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_attack_cross_site_scriptings (
    id integer NOT NULL,
    encloser_type character varying(255) NOT NULL,
    escaper_type character varying(255) NOT NULL,
    evader_type character varying(255) NOT NULL,
    executor_type character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: web_attack_cross_site_scriptings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_attack_cross_site_scriptings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_attack_cross_site_scriptings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_attack_cross_site_scriptings_id_seq OWNED BY web_attack_cross_site_scriptings.id;


--
-- Name: web_cookies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_cookies (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255) NOT NULL,
    request_group_id integer NOT NULL,
    domain character varying(255) NOT NULL,
    path character varying(255),
    secure boolean DEFAULT false NOT NULL,
    http_only boolean DEFAULT false NOT NULL,
    version integer,
    commnet character varying(255),
    comment_url character varying(255),
    discard boolean DEFAULT false NOT NULL,
    ports text,
    max_age integer,
    expires_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: web_cookies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_cookies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_cookies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_cookies_id_seq OWNED BY web_cookies.id;


--
-- Name: web_forms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_forms (
    id integer NOT NULL,
    web_site_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    path text,
    method character varying(1024),
    params text,
    query text
);


--
-- Name: web_forms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_forms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_forms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_forms_id_seq OWNED BY web_forms.id;


--
-- Name: web_headers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_headers (
    id integer NOT NULL,
    attack_vector boolean NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255) NOT NULL,
    "position" integer NOT NULL,
    request_group_id integer NOT NULL
);


--
-- Name: web_headers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_headers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_headers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_headers_id_seq OWNED BY web_headers.id;


--
-- Name: web_pages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_pages (
    id integer NOT NULL,
    web_site_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    path text,
    query text,
    code integer NOT NULL,
    cookie text,
    auth text,
    ctype text,
    mtime timestamp without time zone,
    location text,
    headers text,
    body bytea,
    request bytea
);


--
-- Name: web_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_pages_id_seq OWNED BY web_pages.id;


--
-- Name: web_parameters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_parameters (
    id integer NOT NULL,
    attack_vector boolean NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255) NOT NULL,
    request_id integer NOT NULL,
    "position" integer NOT NULL
);


--
-- Name: web_parameters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_parameters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_parameters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_parameters_id_seq OWNED BY web_parameters.id;


--
-- Name: web_proofs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_proofs (
    id integer NOT NULL,
    image character varying(255),
    text text,
    vuln_id integer NOT NULL
);


--
-- Name: web_proofs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_proofs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_proofs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_proofs_id_seq OWNED BY web_proofs.id;


--
-- Name: web_request_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_request_groups (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer NOT NULL,
    workspace_id integer NOT NULL
);


--
-- Name: web_request_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_request_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_request_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_request_groups_id_seq OWNED BY web_request_groups.id;


--
-- Name: web_requests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_requests (
    id integer NOT NULL,
    method character varying(255) NOT NULL,
    virtual_host_id integer NOT NULL,
    path character varying(255) NOT NULL,
    attack boolean DEFAULT true,
    requested boolean,
    attack_vector boolean,
    request_group_id integer,
    cross_site_scripting_id integer
);


--
-- Name: web_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_requests_id_seq OWNED BY web_requests.id;


--
-- Name: web_sites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_sites (
    id integer NOT NULL,
    service_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    vhost character varying(2048),
    comments text,
    options text
);


--
-- Name: web_sites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_sites_id_seq OWNED BY web_sites.id;


--
-- Name: web_transmitted_cookies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_transmitted_cookies (
    id integer NOT NULL,
    transmitted boolean,
    request_id integer,
    cookie_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: web_transmitted_cookies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_transmitted_cookies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_transmitted_cookies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_transmitted_cookies_id_seq OWNED BY web_transmitted_cookies.id;


--
-- Name: web_transmitted_headers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_transmitted_headers (
    id integer NOT NULL,
    transmitted boolean,
    request_id integer,
    header_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: web_transmitted_headers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_transmitted_headers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_transmitted_headers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_transmitted_headers_id_seq OWNED BY web_transmitted_headers.id;


--
-- Name: web_virtual_hosts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_virtual_hosts (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    service_id integer NOT NULL
);


--
-- Name: web_virtual_hosts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_virtual_hosts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_virtual_hosts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_virtual_hosts_id_seq OWNED BY web_virtual_hosts.id;


--
-- Name: web_vuln_category_metasploits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_vuln_category_metasploits (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    summary character varying(255) NOT NULL
);


--
-- Name: web_vuln_category_metasploits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_vuln_category_metasploits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_vuln_category_metasploits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_vuln_category_metasploits_id_seq OWNED BY web_vuln_category_metasploits.id;


--
-- Name: web_vuln_category_owasps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_vuln_category_owasps (
    id integer NOT NULL,
    detectability character varying(255) NOT NULL,
    exploitability character varying(255) NOT NULL,
    impact character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    prevalence character varying(255) NOT NULL,
    rank integer NOT NULL,
    summary character varying(255) NOT NULL,
    target character varying(255) NOT NULL,
    version character varying(255) NOT NULL
);


--
-- Name: web_vuln_category_owasps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_vuln_category_owasps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_vuln_category_owasps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_vuln_category_owasps_id_seq OWNED BY web_vuln_category_owasps.id;


--
-- Name: web_vuln_category_projection_metasploit_owasps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_vuln_category_projection_metasploit_owasps (
    id integer NOT NULL,
    metasploit_id integer NOT NULL,
    owasp_id integer NOT NULL
);


--
-- Name: web_vuln_category_projection_metasploit_owasps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_vuln_category_projection_metasploit_owasps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_vuln_category_projection_metasploit_owasps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_vuln_category_projection_metasploit_owasps_id_seq OWNED BY web_vuln_category_projection_metasploit_owasps.id;


--
-- Name: web_vulns; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_vulns (
    id integer NOT NULL,
    web_site_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    path text NOT NULL,
    method character varying(1024) NOT NULL,
    params text NOT NULL,
    pname text,
    risk integer NOT NULL,
    name character varying(1024) NOT NULL,
    query text,
    legacy_category text,
    confidence integer NOT NULL,
    description text,
    blame text,
    request bytea,
    owner character varying(255),
    payload text,
    request_id integer,
    category_id integer
);


--
-- Name: web_vulns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_vulns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_vulns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_vulns_id_seq OWNED BY web_vulns.id;


--
-- Name: wizard_procedures; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE wizard_procedures (
    id integer NOT NULL,
    config_hash text,
    state character varying(255),
    task_chain_id integer,
    type character varying(255),
    workspace_id integer,
    user_id integer
);


--
-- Name: wizard_procedures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE wizard_procedures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wizard_procedures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE wizard_procedures_id_seq OWNED BY wizard_procedures.id;


--
-- Name: wmap_requests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE wmap_requests (
    id integer NOT NULL,
    host character varying(255),
    address inet,
    port integer,
    ssl integer,
    meth character varying(32),
    path text,
    headers text,
    query text,
    body text,
    respcode character varying(16),
    resphead text,
    response text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: wmap_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE wmap_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wmap_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE wmap_requests_id_seq OWNED BY wmap_requests.id;


--
-- Name: wmap_targets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE wmap_targets (
    id integer NOT NULL,
    host character varying(255),
    address inet,
    port integer,
    ssl integer,
    selected integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: wmap_targets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE wmap_targets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wmap_targets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE wmap_targets_id_seq OWNED BY wmap_targets.id;


--
-- Name: workspace_members; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE workspace_members (
    workspace_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: workspaces; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE workspaces (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    boundary character varying(4096),
    description character varying(4096),
    owner_id integer,
    limit_to_network boolean DEFAULT false NOT NULL
);


--
-- Name: workspaces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE workspaces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workspaces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE workspaces_id_seq OWNED BY workspaces.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_keys ALTER COLUMN id SET DEFAULT nextval('api_keys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_categories ALTER COLUMN id SET DEFAULT nextval('app_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_categories_apps ALTER COLUMN id SET DEFAULT nextval('app_categories_apps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_runs ALTER COLUMN id SET DEFAULT nextval('app_runs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY apps ALTER COLUMN id SET DEFAULT nextval('apps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY automatic_exploitation_match_results ALTER COLUMN id SET DEFAULT nextval('automatic_exploitation_match_results_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY automatic_exploitation_match_sets ALTER COLUMN id SET DEFAULT nextval('automatic_exploitation_match_sets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY automatic_exploitation_matches ALTER COLUMN id SET DEFAULT nextval('automatic_exploitation_matches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY automatic_exploitation_runs ALTER COLUMN id SET DEFAULT nextval('automatic_exploitation_runs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY brute_force_guess_attempts ALTER COLUMN id SET DEFAULT nextval('brute_force_guess_attempts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY brute_force_guess_cores ALTER COLUMN id SET DEFAULT nextval('brute_force_guess_cores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY brute_force_reuse_attempts ALTER COLUMN id SET DEFAULT nextval('brute_force_reuse_attempts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY brute_force_reuse_groups ALTER COLUMN id SET DEFAULT nextval('brute_force_reuse_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY brute_force_runs ALTER COLUMN id SET DEFAULT nextval('brute_force_runs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY clients ALTER COLUMN id SET DEFAULT nextval('clients_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cred_files ALTER COLUMN id SET DEFAULT nextval('cred_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY creds ALTER COLUMN id SET DEFAULT nextval('creds_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY egadz_result_ranges ALTER COLUMN id SET DEFAULT nextval('egadz_result_ranges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY exploit_attempts ALTER COLUMN id SET DEFAULT nextval('exploit_attempts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY exploited_hosts ALTER COLUMN id SET DEFAULT nextval('exploited_hosts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY exports ALTER COLUMN id SET DEFAULT nextval('exports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY generated_payloads ALTER COLUMN id SET DEFAULT nextval('generated_payloads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY host_details ALTER COLUMN id SET DEFAULT nextval('host_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY hosts ALTER COLUMN id SET DEFAULT nextval('hosts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY hosts_tags ALTER COLUMN id SET DEFAULT nextval('hosts_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY known_ports ALTER COLUMN id SET DEFAULT nextval('known_ports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY listeners ALTER COLUMN id SET DEFAULT nextval('listeners_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY loots ALTER COLUMN id SET DEFAULT nextval('loots_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY macros ALTER COLUMN id SET DEFAULT nextval('macros_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY metasploit_credential_core_tags ALTER COLUMN id SET DEFAULT nextval('metasploit_credential_core_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY metasploit_credential_cores ALTER COLUMN id SET DEFAULT nextval('metasploit_credential_cores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY metasploit_credential_login_tags ALTER COLUMN id SET DEFAULT nextval('metasploit_credential_login_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY metasploit_credential_logins ALTER COLUMN id SET DEFAULT nextval('metasploit_credential_logins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY metasploit_credential_origin_cracked_passwords ALTER COLUMN id SET DEFAULT nextval('metasploit_credential_origin_cracked_passwords_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY metasploit_credential_origin_imports ALTER COLUMN id SET DEFAULT nextval('metasploit_credential_origin_imports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY metasploit_credential_origin_manuals ALTER COLUMN id SET DEFAULT nextval('metasploit_credential_origin_manuals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY metasploit_credential_origin_services ALTER COLUMN id SET DEFAULT nextval('metasploit_credential_origin_services_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY metasploit_credential_origin_sessions ALTER COLUMN id SET DEFAULT nextval('metasploit_credential_origin_sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY metasploit_credential_privates ALTER COLUMN id SET DEFAULT nextval('metasploit_credential_privates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY metasploit_credential_publics ALTER COLUMN id SET DEFAULT nextval('metasploit_credential_publics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY metasploit_credential_realms ALTER COLUMN id SET DEFAULT nextval('metasploit_credential_realms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mm_domino_edges ALTER COLUMN id SET DEFAULT nextval('mm_domino_edges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mm_domino_nodes ALTER COLUMN id SET DEFAULT nextval('mm_domino_nodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mm_domino_nodes_cores ALTER COLUMN id SET DEFAULT nextval('mm_domino_nodes_cores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mod_refs ALTER COLUMN id SET DEFAULT nextval('mod_refs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY module_actions ALTER COLUMN id SET DEFAULT nextval('module_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY module_archs ALTER COLUMN id SET DEFAULT nextval('module_archs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY module_authors ALTER COLUMN id SET DEFAULT nextval('module_authors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY module_details ALTER COLUMN id SET DEFAULT nextval('module_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY module_mixins ALTER COLUMN id SET DEFAULT nextval('module_mixins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY module_platforms ALTER COLUMN id SET DEFAULT nextval('module_platforms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY module_refs ALTER COLUMN id SET DEFAULT nextval('module_refs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY module_targets ALTER COLUMN id SET DEFAULT nextval('module_targets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nexpose_consoles ALTER COLUMN id SET DEFAULT nextval('nexpose_consoles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nexpose_data_assets ALTER COLUMN id SET DEFAULT nextval('nexpose_data_assets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nexpose_data_exploits ALTER COLUMN id SET DEFAULT nextval('nexpose_data_exploits_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nexpose_data_import_runs ALTER COLUMN id SET DEFAULT nextval('nexpose_data_import_runs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nexpose_data_ip_addresses ALTER COLUMN id SET DEFAULT nextval('nexpose_data_ip_addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nexpose_data_scan_templates ALTER COLUMN id SET DEFAULT nextval('nexpose_data_scan_templates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nexpose_data_sites ALTER COLUMN id SET DEFAULT nextval('nexpose_data_sites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nexpose_data_vulnerabilities ALTER COLUMN id SET DEFAULT nextval('nexpose_data_vulnerabilities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nexpose_data_vulnerability_definitions ALTER COLUMN id SET DEFAULT nextval('nexpose_data_vulnerability_definitions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nexpose_data_vulnerability_instances ALTER COLUMN id SET DEFAULT nextval('nexpose_data_vulnerability_instances_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nexpose_data_vulnerability_references ALTER COLUMN id SET DEFAULT nextval('nexpose_data_vulnerability_references_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nexpose_result_exceptions ALTER COLUMN id SET DEFAULT nextval('nexpose_result_exceptions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nexpose_result_export_runs ALTER COLUMN id SET DEFAULT nextval('nexpose_result_export_runs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nexpose_result_validations ALTER COLUMN id SET DEFAULT nextval('nexpose_result_validations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notes ALTER COLUMN id SET DEFAULT nextval('notes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notification_messages ALTER COLUMN id SET DEFAULT nextval('notification_messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notification_messages_users ALTER COLUMN id SET DEFAULT nextval('notification_messages_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pnd_pcap_files ALTER COLUMN id SET DEFAULT nextval('pnd_pcap_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles ALTER COLUMN id SET DEFAULT nextval('profiles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY refs ALTER COLUMN id SET DEFAULT nextval('refs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY report_artifacts ALTER COLUMN id SET DEFAULT nextval('report_artifacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY report_custom_resources ALTER COLUMN id SET DEFAULT nextval('report_custom_resources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports ALTER COLUMN id SET DEFAULT nextval('reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY routes ALTER COLUMN id SET DEFAULT nextval('routes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY run_stats ALTER COLUMN id SET DEFAULT nextval('run_stats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scheduled_tasks ALTER COLUMN id SET DEFAULT nextval('scheduled_tasks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY se_campaign_files ALTER COLUMN id SET DEFAULT nextval('se_campaign_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY se_campaigns ALTER COLUMN id SET DEFAULT nextval('se_campaigns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY se_email_openings ALTER COLUMN id SET DEFAULT nextval('se_email_openings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY se_email_sends ALTER COLUMN id SET DEFAULT nextval('se_email_sends_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY se_email_templates ALTER COLUMN id SET DEFAULT nextval('se_email_templates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY se_emails ALTER COLUMN id SET DEFAULT nextval('se_emails_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY se_human_targets ALTER COLUMN id SET DEFAULT nextval('se_human_targets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY se_phishing_results ALTER COLUMN id SET DEFAULT nextval('se_phishing_results_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY se_portable_files ALTER COLUMN id SET DEFAULT nextval('se_portable_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY se_target_list_human_targets ALTER COLUMN id SET DEFAULT nextval('se_target_list_human_targets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY se_target_lists ALTER COLUMN id SET DEFAULT nextval('se_target_lists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY se_tracking_links ALTER COLUMN id SET DEFAULT nextval('se_tracking_links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY se_visits ALTER COLUMN id SET DEFAULT nextval('se_visits_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY se_web_pages ALTER COLUMN id SET DEFAULT nextval('se_web_pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY se_web_templates ALTER COLUMN id SET DEFAULT nextval('se_web_templates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY services ALTER COLUMN id SET DEFAULT nextval('services_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY session_events ALTER COLUMN id SET DEFAULT nextval('session_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions ALTER COLUMN id SET DEFAULT nextval('sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY task_chains ALTER COLUMN id SET DEFAULT nextval('task_chains_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY task_creds ALTER COLUMN id SET DEFAULT nextval('task_creds_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY task_hosts ALTER COLUMN id SET DEFAULT nextval('task_hosts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY task_services ALTER COLUMN id SET DEFAULT nextval('task_services_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY task_sessions ALTER COLUMN id SET DEFAULT nextval('task_sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tasks ALTER COLUMN id SET DEFAULT nextval('tasks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vuln_attempts ALTER COLUMN id SET DEFAULT nextval('vuln_attempts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vuln_details ALTER COLUMN id SET DEFAULT nextval('vuln_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulns ALTER COLUMN id SET DEFAULT nextval('vulns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulns_refs ALTER COLUMN id SET DEFAULT nextval('vulns_refs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_attack_cross_site_scriptings ALTER COLUMN id SET DEFAULT nextval('web_attack_cross_site_scriptings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_cookies ALTER COLUMN id SET DEFAULT nextval('web_cookies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_forms ALTER COLUMN id SET DEFAULT nextval('web_forms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_headers ALTER COLUMN id SET DEFAULT nextval('web_headers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_pages ALTER COLUMN id SET DEFAULT nextval('web_pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_parameters ALTER COLUMN id SET DEFAULT nextval('web_parameters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_proofs ALTER COLUMN id SET DEFAULT nextval('web_proofs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_request_groups ALTER COLUMN id SET DEFAULT nextval('web_request_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_requests ALTER COLUMN id SET DEFAULT nextval('web_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_sites ALTER COLUMN id SET DEFAULT nextval('web_sites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_transmitted_cookies ALTER COLUMN id SET DEFAULT nextval('web_transmitted_cookies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_transmitted_headers ALTER COLUMN id SET DEFAULT nextval('web_transmitted_headers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_virtual_hosts ALTER COLUMN id SET DEFAULT nextval('web_virtual_hosts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_vuln_category_metasploits ALTER COLUMN id SET DEFAULT nextval('web_vuln_category_metasploits_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_vuln_category_owasps ALTER COLUMN id SET DEFAULT nextval('web_vuln_category_owasps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_vuln_category_projection_metasploit_owasps ALTER COLUMN id SET DEFAULT nextval('web_vuln_category_projection_metasploit_owasps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_vulns ALTER COLUMN id SET DEFAULT nextval('web_vulns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY wizard_procedures ALTER COLUMN id SET DEFAULT nextval('wizard_procedures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY wmap_requests ALTER COLUMN id SET DEFAULT nextval('wmap_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY wmap_targets ALTER COLUMN id SET DEFAULT nextval('wmap_targets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY workspaces ALTER COLUMN id SET DEFAULT nextval('workspaces_id_seq'::regclass);


--
-- Name: api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: app_categories_apps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY app_categories_apps
    ADD CONSTRAINT app_categories_apps_pkey PRIMARY KEY (id);


--
-- Name: app_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY app_categories
    ADD CONSTRAINT app_categories_pkey PRIMARY KEY (id);


--
-- Name: app_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY app_runs
    ADD CONSTRAINT app_runs_pkey PRIMARY KEY (id);


--
-- Name: apps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY apps
    ADD CONSTRAINT apps_pkey PRIMARY KEY (id);


--
-- Name: automatic_exploitation_match_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY automatic_exploitation_match_results
    ADD CONSTRAINT automatic_exploitation_match_results_pkey PRIMARY KEY (id);


--
-- Name: automatic_exploitation_match_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY automatic_exploitation_match_sets
    ADD CONSTRAINT automatic_exploitation_match_sets_pkey PRIMARY KEY (id);


--
-- Name: automatic_exploitation_matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY automatic_exploitation_matches
    ADD CONSTRAINT automatic_exploitation_matches_pkey PRIMARY KEY (id);


--
-- Name: automatic_exploitation_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY automatic_exploitation_runs
    ADD CONSTRAINT automatic_exploitation_runs_pkey PRIMARY KEY (id);


--
-- Name: brute_force_guess_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brute_force_guess_attempts
    ADD CONSTRAINT brute_force_guess_attempts_pkey PRIMARY KEY (id);


--
-- Name: brute_force_guess_cores_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brute_force_guess_cores
    ADD CONSTRAINT brute_force_guess_cores_pkey PRIMARY KEY (id);


--
-- Name: brute_force_reuse_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brute_force_reuse_attempts
    ADD CONSTRAINT brute_force_reuse_attempts_pkey PRIMARY KEY (id);


--
-- Name: brute_force_reuse_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brute_force_reuse_groups
    ADD CONSTRAINT brute_force_reuse_groups_pkey PRIMARY KEY (id);


--
-- Name: brute_force_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brute_force_runs
    ADD CONSTRAINT brute_force_runs_pkey PRIMARY KEY (id);


--
-- Name: clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: cred_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cred_files
    ADD CONSTRAINT cred_files_pkey PRIMARY KEY (id);


--
-- Name: creds_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY creds
    ADD CONSTRAINT creds_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: egadz_result_ranges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY egadz_result_ranges
    ADD CONSTRAINT egadz_result_ranges_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: exploit_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY exploit_attempts
    ADD CONSTRAINT exploit_attempts_pkey PRIMARY KEY (id);


--
-- Name: exploited_hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY exploited_hosts
    ADD CONSTRAINT exploited_hosts_pkey PRIMARY KEY (id);


--
-- Name: exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY exports
    ADD CONSTRAINT exports_pkey PRIMARY KEY (id);


--
-- Name: generated_payloads_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY generated_payloads
    ADD CONSTRAINT generated_payloads_pkey PRIMARY KEY (id);


--
-- Name: host_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY host_details
    ADD CONSTRAINT host_details_pkey PRIMARY KEY (id);


--
-- Name: hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY hosts
    ADD CONSTRAINT hosts_pkey PRIMARY KEY (id);


--
-- Name: hosts_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY hosts_tags
    ADD CONSTRAINT hosts_tags_pkey PRIMARY KEY (id);


--
-- Name: known_ports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY known_ports
    ADD CONSTRAINT known_ports_pkey PRIMARY KEY (id);


--
-- Name: listeners_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY listeners
    ADD CONSTRAINT listeners_pkey PRIMARY KEY (id);


--
-- Name: loots_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY loots
    ADD CONSTRAINT loots_pkey PRIMARY KEY (id);


--
-- Name: macros_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY macros
    ADD CONSTRAINT macros_pkey PRIMARY KEY (id);


--
-- Name: metasploit_credential_core_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY metasploit_credential_core_tags
    ADD CONSTRAINT metasploit_credential_core_tags_pkey PRIMARY KEY (id);


--
-- Name: metasploit_credential_cores_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY metasploit_credential_cores
    ADD CONSTRAINT metasploit_credential_cores_pkey PRIMARY KEY (id);


--
-- Name: metasploit_credential_login_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY metasploit_credential_login_tags
    ADD CONSTRAINT metasploit_credential_login_tags_pkey PRIMARY KEY (id);


--
-- Name: metasploit_credential_logins_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY metasploit_credential_logins
    ADD CONSTRAINT metasploit_credential_logins_pkey PRIMARY KEY (id);


--
-- Name: metasploit_credential_origin_cracked_passwords_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY metasploit_credential_origin_cracked_passwords
    ADD CONSTRAINT metasploit_credential_origin_cracked_passwords_pkey PRIMARY KEY (id);


--
-- Name: metasploit_credential_origin_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY metasploit_credential_origin_imports
    ADD CONSTRAINT metasploit_credential_origin_imports_pkey PRIMARY KEY (id);


--
-- Name: metasploit_credential_origin_manuals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY metasploit_credential_origin_manuals
    ADD CONSTRAINT metasploit_credential_origin_manuals_pkey PRIMARY KEY (id);


--
-- Name: metasploit_credential_origin_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY metasploit_credential_origin_services
    ADD CONSTRAINT metasploit_credential_origin_services_pkey PRIMARY KEY (id);


--
-- Name: metasploit_credential_origin_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY metasploit_credential_origin_sessions
    ADD CONSTRAINT metasploit_credential_origin_sessions_pkey PRIMARY KEY (id);


--
-- Name: metasploit_credential_privates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY metasploit_credential_privates
    ADD CONSTRAINT metasploit_credential_privates_pkey PRIMARY KEY (id);


--
-- Name: metasploit_credential_publics_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY metasploit_credential_publics
    ADD CONSTRAINT metasploit_credential_publics_pkey PRIMARY KEY (id);


--
-- Name: metasploit_credential_realms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY metasploit_credential_realms
    ADD CONSTRAINT metasploit_credential_realms_pkey PRIMARY KEY (id);


--
-- Name: mm_domino_edges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mm_domino_edges
    ADD CONSTRAINT mm_domino_edges_pkey PRIMARY KEY (id);


--
-- Name: mm_domino_nodes_cores_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mm_domino_nodes_cores
    ADD CONSTRAINT mm_domino_nodes_cores_pkey PRIMARY KEY (id);


--
-- Name: mm_domino_nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mm_domino_nodes
    ADD CONSTRAINT mm_domino_nodes_pkey PRIMARY KEY (id);


--
-- Name: mod_refs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mod_refs
    ADD CONSTRAINT mod_refs_pkey PRIMARY KEY (id);


--
-- Name: module_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY module_actions
    ADD CONSTRAINT module_actions_pkey PRIMARY KEY (id);


--
-- Name: module_archs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY module_archs
    ADD CONSTRAINT module_archs_pkey PRIMARY KEY (id);


--
-- Name: module_authors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY module_authors
    ADD CONSTRAINT module_authors_pkey PRIMARY KEY (id);


--
-- Name: module_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY module_details
    ADD CONSTRAINT module_details_pkey PRIMARY KEY (id);


--
-- Name: module_mixins_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY module_mixins
    ADD CONSTRAINT module_mixins_pkey PRIMARY KEY (id);


--
-- Name: module_platforms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY module_platforms
    ADD CONSTRAINT module_platforms_pkey PRIMARY KEY (id);


--
-- Name: module_refs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY module_refs
    ADD CONSTRAINT module_refs_pkey PRIMARY KEY (id);


--
-- Name: module_targets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY module_targets
    ADD CONSTRAINT module_targets_pkey PRIMARY KEY (id);


--
-- Name: nexpose_consoles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nexpose_consoles
    ADD CONSTRAINT nexpose_consoles_pkey PRIMARY KEY (id);


--
-- Name: nexpose_data_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nexpose_data_assets
    ADD CONSTRAINT nexpose_data_assets_pkey PRIMARY KEY (id);


--
-- Name: nexpose_data_exploits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nexpose_data_exploits
    ADD CONSTRAINT nexpose_data_exploits_pkey PRIMARY KEY (id);


--
-- Name: nexpose_data_import_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nexpose_data_import_runs
    ADD CONSTRAINT nexpose_data_import_runs_pkey PRIMARY KEY (id);


--
-- Name: nexpose_data_ip_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nexpose_data_ip_addresses
    ADD CONSTRAINT nexpose_data_ip_addresses_pkey PRIMARY KEY (id);


--
-- Name: nexpose_data_scan_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nexpose_data_scan_templates
    ADD CONSTRAINT nexpose_data_scan_templates_pkey PRIMARY KEY (id);


--
-- Name: nexpose_data_sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nexpose_data_sites
    ADD CONSTRAINT nexpose_data_sites_pkey PRIMARY KEY (id);


--
-- Name: nexpose_data_vulnerabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nexpose_data_vulnerabilities
    ADD CONSTRAINT nexpose_data_vulnerabilities_pkey PRIMARY KEY (id);


--
-- Name: nexpose_data_vulnerability_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nexpose_data_vulnerability_definitions
    ADD CONSTRAINT nexpose_data_vulnerability_definitions_pkey PRIMARY KEY (id);


--
-- Name: nexpose_data_vulnerability_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nexpose_data_vulnerability_instances
    ADD CONSTRAINT nexpose_data_vulnerability_instances_pkey PRIMARY KEY (id);


--
-- Name: nexpose_data_vulnerability_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nexpose_data_vulnerability_references
    ADD CONSTRAINT nexpose_data_vulnerability_references_pkey PRIMARY KEY (id);


--
-- Name: nexpose_result_exceptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nexpose_result_exceptions
    ADD CONSTRAINT nexpose_result_exceptions_pkey PRIMARY KEY (id);


--
-- Name: nexpose_result_export_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nexpose_result_export_runs
    ADD CONSTRAINT nexpose_result_export_runs_pkey PRIMARY KEY (id);


--
-- Name: nexpose_result_validations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nexpose_result_validations
    ADD CONSTRAINT nexpose_result_validations_pkey PRIMARY KEY (id);


--
-- Name: notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: notification_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notification_messages
    ADD CONSTRAINT notification_messages_pkey PRIMARY KEY (id);


--
-- Name: notification_messages_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notification_messages_users
    ADD CONSTRAINT notification_messages_users_pkey PRIMARY KEY (id);


--
-- Name: pnd_pcap_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pnd_pcap_files
    ADD CONSTRAINT pnd_pcap_files_pkey PRIMARY KEY (id);


--
-- Name: profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: refs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY refs
    ADD CONSTRAINT refs_pkey PRIMARY KEY (id);


--
-- Name: report_artifacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY report_artifacts
    ADD CONSTRAINT report_artifacts_pkey PRIMARY KEY (id);


--
-- Name: report_custom_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY report_custom_resources
    ADD CONSTRAINT report_custom_resources_pkey PRIMARY KEY (id);


--
-- Name: reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- Name: routes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id);


--
-- Name: run_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY run_stats
    ADD CONSTRAINT run_stats_pkey PRIMARY KEY (id);


--
-- Name: scheduled_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scheduled_tasks
    ADD CONSTRAINT scheduled_tasks_pkey PRIMARY KEY (id);


--
-- Name: se_attack_list_human_targets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY se_target_list_human_targets
    ADD CONSTRAINT se_attack_list_human_targets_pkey PRIMARY KEY (id);


--
-- Name: se_attack_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY se_target_lists
    ADD CONSTRAINT se_attack_lists_pkey PRIMARY KEY (id);


--
-- Name: se_campaign_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY se_campaign_files
    ADD CONSTRAINT se_campaign_files_pkey PRIMARY KEY (id);


--
-- Name: se_campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY se_campaigns
    ADD CONSTRAINT se_campaigns_pkey PRIMARY KEY (id);


--
-- Name: se_email_openings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY se_email_openings
    ADD CONSTRAINT se_email_openings_pkey PRIMARY KEY (id);


--
-- Name: se_email_sends_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY se_email_sends
    ADD CONSTRAINT se_email_sends_pkey PRIMARY KEY (id);


--
-- Name: se_email_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY se_email_templates
    ADD CONSTRAINT se_email_templates_pkey PRIMARY KEY (id);


--
-- Name: se_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY se_emails
    ADD CONSTRAINT se_emails_pkey PRIMARY KEY (id);


--
-- Name: se_human_targets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY se_human_targets
    ADD CONSTRAINT se_human_targets_pkey PRIMARY KEY (id);


--
-- Name: se_phishing_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY se_phishing_results
    ADD CONSTRAINT se_phishing_results_pkey PRIMARY KEY (id);


--
-- Name: se_tracking_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY se_tracking_links
    ADD CONSTRAINT se_tracking_links_pkey PRIMARY KEY (id);


--
-- Name: se_usb_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY se_portable_files
    ADD CONSTRAINT se_usb_keys_pkey PRIMARY KEY (id);


--
-- Name: se_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY se_visits
    ADD CONSTRAINT se_visits_pkey PRIMARY KEY (id);


--
-- Name: se_web_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY se_web_pages
    ADD CONSTRAINT se_web_pages_pkey PRIMARY KEY (id);


--
-- Name: se_web_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY se_web_templates
    ADD CONSTRAINT se_web_templates_pkey PRIMARY KEY (id);


--
-- Name: services_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: session_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY session_events
    ADD CONSTRAINT session_events_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: task_chains_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY task_chains
    ADD CONSTRAINT task_chains_pkey PRIMARY KEY (id);


--
-- Name: task_creds_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY task_creds
    ADD CONSTRAINT task_creds_pkey PRIMARY KEY (id);


--
-- Name: task_hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY task_hosts
    ADD CONSTRAINT task_hosts_pkey PRIMARY KEY (id);


--
-- Name: task_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY task_services
    ADD CONSTRAINT task_services_pkey PRIMARY KEY (id);


--
-- Name: task_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY task_sessions
    ADD CONSTRAINT task_sessions_pkey PRIMARY KEY (id);


--
-- Name: tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vuln_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vuln_attempts
    ADD CONSTRAINT vuln_attempts_pkey PRIMARY KEY (id);


--
-- Name: vuln_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vuln_details
    ADD CONSTRAINT vuln_details_pkey PRIMARY KEY (id);


--
-- Name: vulns_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vulns
    ADD CONSTRAINT vulns_pkey PRIMARY KEY (id);


--
-- Name: vulns_refs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vulns_refs
    ADD CONSTRAINT vulns_refs_pkey PRIMARY KEY (id);


--
-- Name: web_attack_cross_site_scriptings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_attack_cross_site_scriptings
    ADD CONSTRAINT web_attack_cross_site_scriptings_pkey PRIMARY KEY (id);


--
-- Name: web_cookies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_cookies
    ADD CONSTRAINT web_cookies_pkey PRIMARY KEY (id);


--
-- Name: web_forms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_forms
    ADD CONSTRAINT web_forms_pkey PRIMARY KEY (id);


--
-- Name: web_headers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_headers
    ADD CONSTRAINT web_headers_pkey PRIMARY KEY (id);


--
-- Name: web_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_pages
    ADD CONSTRAINT web_pages_pkey PRIMARY KEY (id);


--
-- Name: web_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_parameters
    ADD CONSTRAINT web_parameters_pkey PRIMARY KEY (id);


--
-- Name: web_proofs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_proofs
    ADD CONSTRAINT web_proofs_pkey PRIMARY KEY (id);


--
-- Name: web_request_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_request_groups
    ADD CONSTRAINT web_request_groups_pkey PRIMARY KEY (id);


--
-- Name: web_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_requests
    ADD CONSTRAINT web_requests_pkey PRIMARY KEY (id);


--
-- Name: web_sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_sites
    ADD CONSTRAINT web_sites_pkey PRIMARY KEY (id);


--
-- Name: web_transmitted_cookies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_transmitted_cookies
    ADD CONSTRAINT web_transmitted_cookies_pkey PRIMARY KEY (id);


--
-- Name: web_transmitted_headers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_transmitted_headers
    ADD CONSTRAINT web_transmitted_headers_pkey PRIMARY KEY (id);


--
-- Name: web_virtual_hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_virtual_hosts
    ADD CONSTRAINT web_virtual_hosts_pkey PRIMARY KEY (id);


--
-- Name: web_vuln_category_metasploits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_vuln_category_metasploits
    ADD CONSTRAINT web_vuln_category_metasploits_pkey PRIMARY KEY (id);


--
-- Name: web_vuln_category_owasps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_vuln_category_owasps
    ADD CONSTRAINT web_vuln_category_owasps_pkey PRIMARY KEY (id);


--
-- Name: web_vuln_category_projection_metasploit_owasps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_vuln_category_projection_metasploit_owasps
    ADD CONSTRAINT web_vuln_category_projection_metasploit_owasps_pkey PRIMARY KEY (id);


--
-- Name: web_vulns_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_vulns
    ADD CONSTRAINT web_vulns_pkey PRIMARY KEY (id);


--
-- Name: wizard_procedures_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wizard_procedures
    ADD CONSTRAINT wizard_procedures_pkey PRIMARY KEY (id);


--
-- Name: wmap_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wmap_requests
    ADD CONSTRAINT wmap_requests_pkey PRIMARY KEY (id);


--
-- Name: wmap_targets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wmap_targets
    ADD CONSTRAINT wmap_targets_pkey PRIMARY KEY (id);


--
-- Name: workspaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY workspaces
    ADD CONSTRAINT workspaces_pkey PRIMARY KEY (id);


--
-- Name: brute_force_guess_attempts_brute_force_guess_core_ids; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX brute_force_guess_attempts_brute_force_guess_core_ids ON brute_force_guess_attempts USING btree (brute_force_guess_core_id);


--
-- Name: brute_force_reuse_attempts_metasploit_credential_core_ids; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX brute_force_reuse_attempts_metasploit_credential_core_ids ON brute_force_reuse_attempts USING btree (metasploit_credential_core_id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: index_app_categories_apps_on_app_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_app_categories_apps_on_app_category_id ON app_categories_apps USING btree (app_category_id);


--
-- Name: index_app_categories_apps_on_app_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_app_categories_apps_on_app_id ON app_categories_apps USING btree (app_id);


--
-- Name: index_app_runs_on_app_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_app_runs_on_app_id ON app_runs USING btree (app_id);


--
-- Name: index_app_runs_on_workspace_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_app_runs_on_workspace_id ON app_runs USING btree (workspace_id);


--
-- Name: index_automatic_exploitation_match_sets_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_automatic_exploitation_match_sets_on_user_id ON automatic_exploitation_match_sets USING btree (user_id);


--
-- Name: index_automatic_exploitation_match_sets_on_workspace_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_automatic_exploitation_match_sets_on_workspace_id ON automatic_exploitation_match_sets USING btree (workspace_id);


--
-- Name: index_automatic_exploitation_matches_on_nexpose_data_exploit_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_automatic_exploitation_matches_on_nexpose_data_exploit_id ON automatic_exploitation_matches USING btree (nexpose_data_exploit_id);


--
-- Name: index_automatic_exploitation_matches_on_ref_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_automatic_exploitation_matches_on_ref_id ON automatic_exploitation_matches USING btree (module_detail_id);


--
-- Name: index_automatic_exploitation_matches_on_vuln_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_automatic_exploitation_matches_on_vuln_id ON automatic_exploitation_matches USING btree (vuln_id);


--
-- Name: index_brute_force_guess_attempts_on_service_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_brute_force_guess_attempts_on_service_id ON brute_force_guess_attempts USING btree (service_id);


--
-- Name: index_brute_force_guess_cores_on_private_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_brute_force_guess_cores_on_private_id ON brute_force_guess_cores USING btree (private_id);


--
-- Name: index_brute_force_guess_cores_on_public_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_brute_force_guess_cores_on_public_id ON brute_force_guess_cores USING btree (public_id);


--
-- Name: index_brute_force_guess_cores_on_realm_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_brute_force_guess_cores_on_realm_id ON brute_force_guess_cores USING btree (realm_id);


--
-- Name: index_brute_force_guess_cores_on_workspace_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_brute_force_guess_cores_on_workspace_id ON brute_force_guess_cores USING btree (workspace_id);


--
-- Name: index_brute_force_reuse_attempts_on_service_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_brute_force_reuse_attempts_on_service_id ON brute_force_reuse_attempts USING btree (service_id);


--
-- Name: index_brute_force_reuse_groups_on_workspace_id_and_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_brute_force_reuse_groups_on_workspace_id_and_name ON brute_force_reuse_groups USING btree (workspace_id, name);


--
-- Name: index_hosts_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_hosts_on_name ON hosts USING btree (name);


--
-- Name: index_hosts_on_os_flavor; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_hosts_on_os_flavor ON hosts USING btree (os_flavor);


--
-- Name: index_hosts_on_os_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_hosts_on_os_name ON hosts USING btree (os_name);


--
-- Name: index_hosts_on_purpose; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_hosts_on_purpose ON hosts USING btree (purpose);


--
-- Name: index_hosts_on_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_hosts_on_state ON hosts USING btree (state);


--
-- Name: index_hosts_on_workspace_id_and_address; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_hosts_on_workspace_id_and_address ON hosts USING btree (workspace_id, address);


--
-- Name: index_known_ports_on_port; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_known_ports_on_port ON known_ports USING btree (port);


--
-- Name: index_metasploit_credential_core_tags_on_core_id_and_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_metasploit_credential_core_tags_on_core_id_and_tag_id ON metasploit_credential_core_tags USING btree (core_id, tag_id);


--
-- Name: index_metasploit_credential_cores_on_origin_type_and_origin_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_metasploit_credential_cores_on_origin_type_and_origin_id ON metasploit_credential_cores USING btree (origin_type, origin_id);


--
-- Name: index_metasploit_credential_cores_on_private_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_metasploit_credential_cores_on_private_id ON metasploit_credential_cores USING btree (private_id);


--
-- Name: index_metasploit_credential_cores_on_public_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_metasploit_credential_cores_on_public_id ON metasploit_credential_cores USING btree (public_id);


--
-- Name: index_metasploit_credential_cores_on_realm_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_metasploit_credential_cores_on_realm_id ON metasploit_credential_cores USING btree (realm_id);


--
-- Name: index_metasploit_credential_cores_on_workspace_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_metasploit_credential_cores_on_workspace_id ON metasploit_credential_cores USING btree (workspace_id);


--
-- Name: index_metasploit_credential_login_tags_on_login_id_and_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_metasploit_credential_login_tags_on_login_id_and_tag_id ON metasploit_credential_login_tags USING btree (login_id, tag_id);


--
-- Name: index_metasploit_credential_logins_on_core_id_and_service_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_metasploit_credential_logins_on_core_id_and_service_id ON metasploit_credential_logins USING btree (core_id, service_id);


--
-- Name: index_metasploit_credential_logins_on_service_id_and_core_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_metasploit_credential_logins_on_service_id_and_core_id ON metasploit_credential_logins USING btree (service_id, core_id);


--
-- Name: index_metasploit_credential_origin_imports_on_task_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_metasploit_credential_origin_imports_on_task_id ON metasploit_credential_origin_imports USING btree (task_id);


--
-- Name: index_metasploit_credential_origin_manuals_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_metasploit_credential_origin_manuals_on_user_id ON metasploit_credential_origin_manuals USING btree (user_id);


--
-- Name: index_metasploit_credential_privates_on_type_and_data; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_metasploit_credential_privates_on_type_and_data ON metasploit_credential_privates USING btree (type, data);


--
-- Name: index_metasploit_credential_publics_on_username; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_metasploit_credential_publics_on_username ON metasploit_credential_publics USING btree (username);


--
-- Name: index_metasploit_credential_realms_on_key_and_value; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_metasploit_credential_realms_on_key_and_value ON metasploit_credential_realms USING btree (key, value);


--
-- Name: index_mm_domino_edges_on_dest_node_id_and_run_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_mm_domino_edges_on_dest_node_id_and_run_id ON mm_domino_edges USING btree (dest_node_id, run_id);


--
-- Name: index_mm_domino_edges_on_login_id_and_run_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_mm_domino_edges_on_login_id_and_run_id ON mm_domino_edges USING btree (login_id, run_id);


--
-- Name: index_mm_domino_edges_on_run_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_mm_domino_edges_on_run_id ON mm_domino_edges USING btree (run_id);


--
-- Name: index_mm_domino_nodes_cores_on_node_id_and_core_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_mm_domino_nodes_cores_on_node_id_and_core_id ON mm_domino_nodes_cores USING btree (node_id, core_id);


--
-- Name: index_mm_domino_nodes_on_host_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_mm_domino_nodes_on_host_id ON mm_domino_nodes USING btree (host_id);


--
-- Name: index_mm_domino_nodes_on_host_id_and_run_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_mm_domino_nodes_on_host_id_and_run_id ON mm_domino_nodes USING btree (host_id, run_id);


--
-- Name: index_mm_domino_nodes_on_run_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_mm_domino_nodes_on_run_id ON mm_domino_nodes USING btree (run_id);


--
-- Name: index_module_actions_on_module_detail_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_module_actions_on_module_detail_id ON module_actions USING btree (detail_id);


--
-- Name: index_module_archs_on_module_detail_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_module_archs_on_module_detail_id ON module_archs USING btree (detail_id);


--
-- Name: index_module_authors_on_module_detail_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_module_authors_on_module_detail_id ON module_authors USING btree (detail_id);


--
-- Name: index_module_details_on_description; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_module_details_on_description ON module_details USING btree (description);


--
-- Name: index_module_details_on_mtype; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_module_details_on_mtype ON module_details USING btree (mtype);


--
-- Name: index_module_details_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_module_details_on_name ON module_details USING btree (name);


--
-- Name: index_module_details_on_refname; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_module_details_on_refname ON module_details USING btree (refname);


--
-- Name: index_module_mixins_on_module_detail_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_module_mixins_on_module_detail_id ON module_mixins USING btree (detail_id);


--
-- Name: index_module_platforms_on_module_detail_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_module_platforms_on_module_detail_id ON module_platforms USING btree (detail_id);


--
-- Name: index_module_refs_on_module_detail_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_module_refs_on_module_detail_id ON module_refs USING btree (detail_id);


--
-- Name: index_module_refs_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_module_refs_on_name ON module_refs USING btree (name);


--
-- Name: index_module_targets_on_module_detail_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_module_targets_on_module_detail_id ON module_targets USING btree (detail_id);


--
-- Name: index_nexpose_data_assets_on_asset_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nexpose_data_assets_on_asset_id ON nexpose_data_assets USING btree (asset_id);


--
-- Name: index_nexpose_data_assets_on_nexpose_data_site_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nexpose_data_assets_on_nexpose_data_site_id ON nexpose_data_assets USING btree (nexpose_data_site_id);


--
-- Name: index_nexpose_data_exploits_on_nexpose_exploit_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_nexpose_data_exploits_on_nexpose_exploit_id ON nexpose_data_exploits USING btree (nexpose_exploit_id);


--
-- Name: index_nexpose_data_exploits_on_source_and_source_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nexpose_data_exploits_on_source_and_source_key ON nexpose_data_exploits USING btree (source, source_key);


--
-- Name: index_nexpose_data_import_runs_on_nx_console_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nexpose_data_import_runs_on_nx_console_id ON nexpose_data_import_runs USING btree (nx_console_id);


--
-- Name: index_nexpose_data_ip_addresses_on_nexpose_data_asset_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nexpose_data_ip_addresses_on_nexpose_data_asset_id ON nexpose_data_ip_addresses USING btree (nexpose_data_asset_id);


--
-- Name: index_nexpose_data_scan_templates_on_nx_console_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nexpose_data_scan_templates_on_nx_console_id ON nexpose_data_scan_templates USING btree (nx_console_id);


--
-- Name: index_nexpose_data_scan_templates_on_scan_template_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nexpose_data_scan_templates_on_scan_template_id ON nexpose_data_scan_templates USING btree (scan_template_id);


--
-- Name: index_nexpose_data_sites_on_nexpose_data_import_run_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nexpose_data_sites_on_nexpose_data_import_run_id ON nexpose_data_sites USING btree (nexpose_data_import_run_id);


--
-- Name: index_nexpose_data_sites_on_site_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nexpose_data_sites_on_site_id ON nexpose_data_sites USING btree (site_id);


--
-- Name: index_nexpose_data_vulnerabilities_on_vulnerability_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_nexpose_data_vulnerabilities_on_vulnerability_id ON nexpose_data_vulnerabilities USING btree (vulnerability_id);


--
-- Name: index_nexpose_result_exceptions_on_nexpose_result_export_run_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nexpose_result_exceptions_on_nexpose_result_export_run_id ON nexpose_result_exceptions USING btree (nexpose_result_export_run_id);


--
-- Name: index_nexpose_result_exceptions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nexpose_result_exceptions_on_user_id ON nexpose_result_exceptions USING btree (user_id);


--
-- Name: index_notes_on_notable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notes_on_notable_id ON notes USING btree (notable_id);


--
-- Name: index_notes_on_ntype; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notes_on_ntype ON notes USING btree (ntype);


--
-- Name: index_nx_data_exploits_vuln_defs_on_exploit_id_and_vuln_def_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nx_data_exploits_vuln_defs_on_exploit_id_and_vuln_def_id ON nexpose_data_exploits_vulnerability_definitions USING btree (exploit_id, vulnerability_definition_id);


--
-- Name: index_nx_data_exploits_vuln_defs_on_vuln_def_id_and_exploit_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nx_data_exploits_vuln_defs_on_vuln_def_id_and_exploit_id ON nexpose_data_exploits_vulnerability_definitions USING btree (vulnerability_definition_id, exploit_id);


--
-- Name: index_nx_data_vuln_def_on_vulnerability_definition_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_nx_data_vuln_def_on_vulnerability_definition_id ON nexpose_data_vulnerability_definitions USING btree (vulnerability_definition_id);


--
-- Name: index_nx_data_vuln_inst_on_asset_id_and_vulnerability_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nx_data_vuln_inst_on_asset_id_and_vulnerability_id ON nexpose_data_vulnerability_instances USING btree (asset_id, vulnerability_id);


--
-- Name: index_nx_data_vuln_inst_on_nexpose_data_asset_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nx_data_vuln_inst_on_nexpose_data_asset_id ON nexpose_data_vulnerability_instances USING btree (nexpose_data_asset_id);


--
-- Name: index_nx_data_vuln_inst_on_nexpose_data_vulnerability_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nx_data_vuln_inst_on_nexpose_data_vulnerability_id ON nexpose_data_vulnerability_instances USING btree (nexpose_data_vulnerability_id);


--
-- Name: index_nx_data_vuln_inst_on_vulnerability_id_and_asset_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nx_data_vuln_inst_on_vulnerability_id_and_asset_id ON nexpose_data_vulnerability_instances USING btree (vulnerability_id, asset_id);


--
-- Name: index_nx_data_vuln_on_nexpose_data_vuln_def_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nx_data_vuln_on_nexpose_data_vuln_def_id ON nexpose_data_vulnerabilities USING btree (nexpose_data_vulnerability_definition_id);


--
-- Name: index_nx_r_exceptions_on_nx_scope_type_and_nx_scope_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nx_r_exceptions_on_nx_scope_type_and_nx_scope_id ON nexpose_result_exceptions USING btree (nx_scope_type, nx_scope_id);


--
-- Name: index_nx_result_validations_on_nx_result_export_run_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nx_result_validations_on_nx_result_export_run_id ON nexpose_result_validations USING btree (nexpose_result_export_run_id);


--
-- Name: index_refs_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_refs_on_name ON refs USING btree (name);


--
-- Name: index_services_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_services_on_name ON services USING btree (name);


--
-- Name: index_services_on_port; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_services_on_port ON services USING btree (port);


--
-- Name: index_services_on_proto; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_services_on_proto ON services USING btree (proto);


--
-- Name: index_services_on_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_services_on_state ON services USING btree (state);


--
-- Name: index_vulns_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulns_on_name ON vulns USING btree (name);


--
-- Name: index_vulns_on_nexpose_data_vuln_def_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulns_on_nexpose_data_vuln_def_id ON vulns USING btree (nexpose_data_vuln_def_id);


--
-- Name: index_web_cookies_on_request_group_id_and_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_web_cookies_on_request_group_id_and_name ON web_cookies USING btree (request_group_id, name);


--
-- Name: index_web_forms_on_path; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_web_forms_on_path ON web_forms USING btree (path);


--
-- Name: index_web_pages_on_path; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_web_pages_on_path ON web_pages USING btree (path);


--
-- Name: index_web_pages_on_query; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_web_pages_on_query ON web_pages USING btree (query);


--
-- Name: index_web_requests_on_cross_site_scripting_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_web_requests_on_cross_site_scripting_id ON web_requests USING btree (cross_site_scripting_id);


--
-- Name: index_web_requests_on_request_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_web_requests_on_request_group_id ON web_requests USING btree (request_group_id);


--
-- Name: index_web_sites_on_comments; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_web_sites_on_comments ON web_sites USING btree (comments);


--
-- Name: index_web_sites_on_options; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_web_sites_on_options ON web_sites USING btree (options);


--
-- Name: index_web_sites_on_vhost; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_web_sites_on_vhost ON web_sites USING btree (vhost);


--
-- Name: index_web_virtual_hosts_on_service_id_and_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_web_virtual_hosts_on_service_id_and_name ON web_virtual_hosts USING btree (service_id, name);


--
-- Name: index_web_vuln_category_metasploits_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_web_vuln_category_metasploits_on_name ON web_vuln_category_metasploits USING btree (name);


--
-- Name: index_web_vuln_category_owasps_on_target_and_version_and_rank; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_web_vuln_category_owasps_on_target_and_version_and_rank ON web_vuln_category_owasps USING btree (target, version, rank);


--
-- Name: index_web_vuln_category_project_metasploit_id_and_owasp_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_web_vuln_category_project_metasploit_id_and_owasp_id ON web_vuln_category_projection_metasploit_owasps USING btree (metasploit_id, owasp_id);


--
-- Name: index_web_vulns_on_method; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_web_vulns_on_method ON web_vulns USING btree (method);


--
-- Name: index_web_vulns_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_web_vulns_on_name ON web_vulns USING btree (name);


--
-- Name: index_web_vulns_on_path; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_web_vulns_on_path ON web_vulns USING btree (path);


--
-- Name: originating_credential_cores; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX originating_credential_cores ON metasploit_credential_origin_cracked_passwords USING btree (metasploit_credential_core_id);


--
-- Name: unique_brute_force_guess_attempts; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_brute_force_guess_attempts ON brute_force_guess_attempts USING btree (brute_force_run_id, brute_force_guess_core_id, service_id);


--
-- Name: unique_brute_force_reuse_attempts; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_brute_force_reuse_attempts ON brute_force_reuse_attempts USING btree (brute_force_run_id, metasploit_credential_core_id, service_id);


--
-- Name: unique_brute_force_reuse_groups_metasploit_credential_cores; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_brute_force_reuse_groups_metasploit_credential_cores ON brute_force_reuse_groups_metasploit_credential_cores USING btree (brute_force_reuse_group_id, metasploit_credential_core_id);


--
-- Name: unique_complete_metasploit_credential_cores; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_complete_metasploit_credential_cores ON metasploit_credential_cores USING btree (workspace_id, realm_id, public_id, private_id) WHERE (((realm_id IS NOT NULL) AND (public_id IS NOT NULL)) AND (private_id IS NOT NULL));


--
-- Name: unique_metasploit_credential_origin_services; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_metasploit_credential_origin_services ON metasploit_credential_origin_services USING btree (service_id, module_full_name);


--
-- Name: unique_metasploit_credential_origin_sessions; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_metasploit_credential_origin_sessions ON metasploit_credential_origin_sessions USING btree (session_id, post_reference_name);


--
-- Name: unique_private_metasploit_credential_cores; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_private_metasploit_credential_cores ON metasploit_credential_cores USING btree (workspace_id, private_id) WHERE (((realm_id IS NULL) AND (public_id IS NULL)) AND (private_id IS NOT NULL));


--
-- Name: unique_privateless_metasploit_credential_cores; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_privateless_metasploit_credential_cores ON metasploit_credential_cores USING btree (workspace_id, realm_id, public_id) WHERE (((realm_id IS NOT NULL) AND (public_id IS NOT NULL)) AND (private_id IS NULL));


--
-- Name: unique_public_metasploit_credential_cores; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_public_metasploit_credential_cores ON metasploit_credential_cores USING btree (workspace_id, public_id) WHERE (((realm_id IS NULL) AND (public_id IS NOT NULL)) AND (private_id IS NULL));


--
-- Name: unique_publicless_metasploit_credential_cores; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_publicless_metasploit_credential_cores ON metasploit_credential_cores USING btree (workspace_id, realm_id, private_id) WHERE (((realm_id IS NOT NULL) AND (public_id IS NULL)) AND (private_id IS NOT NULL));


--
-- Name: unique_realmless_metasploit_credential_cores; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_realmless_metasploit_credential_cores ON metasploit_credential_cores USING btree (workspace_id, public_id, private_id) WHERE (((realm_id IS NULL) AND (public_id IS NOT NULL)) AND (private_id IS NOT NULL));


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('0');

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('20100819123300');

INSERT INTO schema_migrations (version) VALUES ('20100824151500');

INSERT INTO schema_migrations (version) VALUES ('20100908001428');

INSERT INTO schema_migrations (version) VALUES ('20100911122000');

INSERT INTO schema_migrations (version) VALUES ('20100916151530');

INSERT INTO schema_migrations (version) VALUES ('20100916175000');

INSERT INTO schema_migrations (version) VALUES ('20100920012100');

INSERT INTO schema_migrations (version) VALUES ('20100926214000');

INSERT INTO schema_migrations (version) VALUES ('20101001000000');

INSERT INTO schema_migrations (version) VALUES ('20101002000000');

INSERT INTO schema_migrations (version) VALUES ('20101007000000');

INSERT INTO schema_migrations (version) VALUES ('20101008111800');

INSERT INTO schema_migrations (version) VALUES ('20101009023300');

INSERT INTO schema_migrations (version) VALUES ('20101104135100');

INSERT INTO schema_migrations (version) VALUES ('20101203000000');

INSERT INTO schema_migrations (version) VALUES ('20101203000001');

INSERT INTO schema_migrations (version) VALUES ('20101206212033');

INSERT INTO schema_migrations (version) VALUES ('20110112154300');

INSERT INTO schema_migrations (version) VALUES ('20110204112800');

INSERT INTO schema_migrations (version) VALUES ('20110317144932');

INSERT INTO schema_migrations (version) VALUES ('20110414180600');

INSERT INTO schema_migrations (version) VALUES ('20110415175705');

INSERT INTO schema_migrations (version) VALUES ('20110422000000');

INSERT INTO schema_migrations (version) VALUES ('20110425095900');

INSERT INTO schema_migrations (version) VALUES ('20110513143900');

INSERT INTO schema_migrations (version) VALUES ('20110517160800');

INSERT INTO schema_migrations (version) VALUES ('20110527000000');

INSERT INTO schema_migrations (version) VALUES ('20110527000001');

INSERT INTO schema_migrations (version) VALUES ('20110606000001');

INSERT INTO schema_migrations (version) VALUES ('20110608113500');

INSERT INTO schema_migrations (version) VALUES ('20110622000000');

INSERT INTO schema_migrations (version) VALUES ('20110624000001');

INSERT INTO schema_migrations (version) VALUES ('20110625000001');

INSERT INTO schema_migrations (version) VALUES ('20110630000001');

INSERT INTO schema_migrations (version) VALUES ('20110630000002');

INSERT INTO schema_migrations (version) VALUES ('20110717000001');

INSERT INTO schema_migrations (version) VALUES ('20110727163801');

INSERT INTO schema_migrations (version) VALUES ('20110730000001');

INSERT INTO schema_migrations (version) VALUES ('20110812000001');

INSERT INTO schema_migrations (version) VALUES ('20110922000000');

INSERT INTO schema_migrations (version) VALUES ('20110928101300');

INSERT INTO schema_migrations (version) VALUES ('20111011110000');

INSERT INTO schema_migrations (version) VALUES ('20111203000000');

INSERT INTO schema_migrations (version) VALUES ('20111204000000');

INSERT INTO schema_migrations (version) VALUES ('20111210000000');

INSERT INTO schema_migrations (version) VALUES ('20120126110000');

INSERT INTO schema_migrations (version) VALUES ('20120214173547');

INSERT INTO schema_migrations (version) VALUES ('20120214180627');

INSERT INTO schema_migrations (version) VALUES ('20120216175354');

INSERT INTO schema_migrations (version) VALUES ('20120222200922');

INSERT INTO schema_migrations (version) VALUES ('20120222211846');

INSERT INTO schema_migrations (version) VALUES ('20120222215615');

INSERT INTO schema_migrations (version) VALUES ('20120224210032');

INSERT INTO schema_migrations (version) VALUES ('20120224210251');

INSERT INTO schema_migrations (version) VALUES ('20120302211405');

INSERT INTO schema_migrations (version) VALUES ('20120322034657');

INSERT INTO schema_migrations (version) VALUES ('20120322035142');

INSERT INTO schema_migrations (version) VALUES ('20120327234013');

INSERT INTO schema_migrations (version) VALUES ('20120402171703');

INSERT INTO schema_migrations (version) VALUES ('20120411173220');

INSERT INTO schema_migrations (version) VALUES ('20120508153439');

INSERT INTO schema_migrations (version) VALUES ('20120521200021');

INSERT INTO schema_migrations (version) VALUES ('20120601152442');

INSERT INTO schema_migrations (version) VALUES ('20120607205748');

INSERT INTO schema_migrations (version) VALUES ('20120611022859');

INSERT INTO schema_migrations (version) VALUES ('20120611151726');

INSERT INTO schema_migrations (version) VALUES ('20120615191457');

INSERT INTO schema_migrations (version) VALUES ('20120619201707');

INSERT INTO schema_migrations (version) VALUES ('20120620144555');

INSERT INTO schema_migrations (version) VALUES ('20120621231906');

INSERT INTO schema_migrations (version) VALUES ('20120622204822');

INSERT INTO schema_migrations (version) VALUES ('20120622211713');

INSERT INTO schema_migrations (version) VALUES ('20120624211412');

INSERT INTO schema_migrations (version) VALUES ('20120625000000');

INSERT INTO schema_migrations (version) VALUES ('20120625000001');

INSERT INTO schema_migrations (version) VALUES ('20120625000002');

INSERT INTO schema_migrations (version) VALUES ('20120625000003');

INSERT INTO schema_migrations (version) VALUES ('20120625000004');

INSERT INTO schema_migrations (version) VALUES ('20120625000005');

INSERT INTO schema_migrations (version) VALUES ('20120625000006');

INSERT INTO schema_migrations (version) VALUES ('20120625000007');

INSERT INTO schema_migrations (version) VALUES ('20120625000008');

INSERT INTO schema_migrations (version) VALUES ('20120627170349');

INSERT INTO schema_migrations (version) VALUES ('20120628212319');

INSERT INTO schema_migrations (version) VALUES ('20120629171559');

INSERT INTO schema_migrations (version) VALUES ('20120702232922');

INSERT INTO schema_migrations (version) VALUES ('20120705220353');

INSERT INTO schema_migrations (version) VALUES ('20120706214120');

INSERT INTO schema_migrations (version) VALUES ('20120709182326');

INSERT INTO schema_migrations (version) VALUES ('20120709190111');

INSERT INTO schema_migrations (version) VALUES ('20120709190832');

INSERT INTO schema_migrations (version) VALUES ('20120710024953');

INSERT INTO schema_migrations (version) VALUES ('20120710221438');

INSERT INTO schema_migrations (version) VALUES ('20120711171500');

INSERT INTO schema_migrations (version) VALUES ('20120718202805');

INSERT INTO schema_migrations (version) VALUES ('20120807215156');

INSERT INTO schema_migrations (version) VALUES ('20120808203149');

INSERT INTO schema_migrations (version) VALUES ('20120814152312');

INSERT INTO schema_migrations (version) VALUES ('20120814190330');

INSERT INTO schema_migrations (version) VALUES ('20120820163240');

INSERT INTO schema_migrations (version) VALUES ('20120820164934');

INSERT INTO schema_migrations (version) VALUES ('20120829073017');

INSERT INTO schema_migrations (version) VALUES ('20120829183633');

INSERT INTO schema_migrations (version) VALUES ('20120830204014');

INSERT INTO schema_migrations (version) VALUES ('20120907202200');

INSERT INTO schema_migrations (version) VALUES ('20120919185804');

INSERT INTO schema_migrations (version) VALUES ('20121001202233');

INSERT INTO schema_migrations (version) VALUES ('20121004142927');

INSERT INTO schema_migrations (version) VALUES ('20121023183338');

INSERT INTO schema_migrations (version) VALUES ('20121112185301');

INSERT INTO schema_migrations (version) VALUES ('20121114171655');

INSERT INTO schema_migrations (version) VALUES ('20121116213357');

INSERT INTO schema_migrations (version) VALUES ('20121116213558');

INSERT INTO schema_migrations (version) VALUES ('20121116230408');

INSERT INTO schema_migrations (version) VALUES ('20121117071957');

INSERT INTO schema_migrations (version) VALUES ('20130104082355');

INSERT INTO schema_migrations (version) VALUES ('20130104182355');

INSERT INTO schema_migrations (version) VALUES ('20130130153815');

INSERT INTO schema_migrations (version) VALUES ('20130130193940');

INSERT INTO schema_migrations (version) VALUES ('20130130202350');

INSERT INTO schema_migrations (version) VALUES ('20130130215920');

INSERT INTO schema_migrations (version) VALUES ('20130201164531');

INSERT INTO schema_migrations (version) VALUES ('20130206153738');

INSERT INTO schema_migrations (version) VALUES ('20130206170059');

INSERT INTO schema_migrations (version) VALUES ('20130207204554');

INSERT INTO schema_migrations (version) VALUES ('20130208144847');

INSERT INTO schema_migrations (version) VALUES ('20130208192816');

INSERT INTO schema_migrations (version) VALUES ('20130208201622');

INSERT INTO schema_migrations (version) VALUES ('20130208205216');

INSERT INTO schema_migrations (version) VALUES ('20130214172625');

INSERT INTO schema_migrations (version) VALUES ('20130215162238');

INSERT INTO schema_migrations (version) VALUES ('20130216014001');

INSERT INTO schema_migrations (version) VALUES ('20130219151930');

INSERT INTO schema_migrations (version) VALUES ('20130219172323');

INSERT INTO schema_migrations (version) VALUES ('20130219190624');

INSERT INTO schema_migrations (version) VALUES ('20130221033344');

INSERT INTO schema_migrations (version) VALUES ('20130221203157');

INSERT INTO schema_migrations (version) VALUES ('20130221223222');

INSERT INTO schema_migrations (version) VALUES ('20130222175046');

INSERT INTO schema_migrations (version) VALUES ('20130223102526');

INSERT INTO schema_migrations (version) VALUES ('20130223171130');

INSERT INTO schema_migrations (version) VALUES ('20130226151306');

INSERT INTO schema_migrations (version) VALUES ('20130226203506');

INSERT INTO schema_migrations (version) VALUES ('20130226203526');

INSERT INTO schema_migrations (version) VALUES ('20130227191633');

INSERT INTO schema_migrations (version) VALUES ('20130228193109');

INSERT INTO schema_migrations (version) VALUES ('20130228193351');

INSERT INTO schema_migrations (version) VALUES ('20130228204548');

INSERT INTO schema_migrations (version) VALUES ('20130228214900');

INSERT INTO schema_migrations (version) VALUES ('20130228214901');

INSERT INTO schema_migrations (version) VALUES ('20130228214902');

INSERT INTO schema_migrations (version) VALUES ('20130301203008');

INSERT INTO schema_migrations (version) VALUES ('20130305194320');

INSERT INTO schema_migrations (version) VALUES ('20130308191559');

INSERT INTO schema_migrations (version) VALUES ('20130308200346');

INSERT INTO schema_migrations (version) VALUES ('20130308203109');

INSERT INTO schema_migrations (version) VALUES ('20130326155446');

INSERT INTO schema_migrations (version) VALUES ('20130326164623');

INSERT INTO schema_migrations (version) VALUES ('20130327210928');

INSERT INTO schema_migrations (version) VALUES ('20130327212613');

INSERT INTO schema_migrations (version) VALUES ('20130328163951');

INSERT INTO schema_migrations (version) VALUES ('20130402220630');

INSERT INTO schema_migrations (version) VALUES ('20130404162220');

INSERT INTO schema_migrations (version) VALUES ('20130412154159');

INSERT INTO schema_migrations (version) VALUES ('20130412171844');

INSERT INTO schema_migrations (version) VALUES ('20130412173121');

INSERT INTO schema_migrations (version) VALUES ('20130412173640');

INSERT INTO schema_migrations (version) VALUES ('20130412174254');

INSERT INTO schema_migrations (version) VALUES ('20130412174719');

INSERT INTO schema_migrations (version) VALUES ('20130412175040');

INSERT INTO schema_migrations (version) VALUES ('20130423211152');

INSERT INTO schema_migrations (version) VALUES ('20130425275209');

INSERT INTO schema_migrations (version) VALUES ('20130426172211');

INSERT INTO schema_migrations (version) VALUES ('20130430151353');

INSERT INTO schema_migrations (version) VALUES ('20130430162145');

INSERT INTO schema_migrations (version) VALUES ('20130502051220');

INSERT INTO schema_migrations (version) VALUES ('20130502214512');

INSERT INTO schema_migrations (version) VALUES ('20130509204359');

INSERT INTO schema_migrations (version) VALUES ('20130510021637');

INSERT INTO schema_migrations (version) VALUES ('20130510163306');

INSERT INTO schema_migrations (version) VALUES ('20130515164311');

INSERT INTO schema_migrations (version) VALUES ('20130515172727');

INSERT INTO schema_migrations (version) VALUES ('20130516204810');

INSERT INTO schema_migrations (version) VALUES ('20130522001343');

INSERT INTO schema_migrations (version) VALUES ('20130522032517');

INSERT INTO schema_migrations (version) VALUES ('20130522041110');

INSERT INTO schema_migrations (version) VALUES ('20130525015035');

INSERT INTO schema_migrations (version) VALUES ('20130525212420');

INSERT INTO schema_migrations (version) VALUES ('20130529183040');

INSERT INTO schema_migrations (version) VALUES ('20130530184206');

INSERT INTO schema_migrations (version) VALUES ('20130530184216');

INSERT INTO schema_migrations (version) VALUES ('20130530184226');

INSERT INTO schema_migrations (version) VALUES ('20130530184236');

INSERT INTO schema_migrations (version) VALUES ('20130531144949');

INSERT INTO schema_migrations (version) VALUES ('20130603161456');

INSERT INTO schema_migrations (version) VALUES ('20130604145732');

INSERT INTO schema_migrations (version) VALUES ('20130605130805');

INSERT INTO schema_migrations (version) VALUES ('20130605175148');

INSERT INTO schema_migrations (version) VALUES ('20130605180434');

INSERT INTO schema_migrations (version) VALUES ('20130605195015');

INSERT INTO schema_migrations (version) VALUES ('20130611180506');

INSERT INTO schema_migrations (version) VALUES ('20130616200853');

INSERT INTO schema_migrations (version) VALUES ('20130617234902');

INSERT INTO schema_migrations (version) VALUES ('20130618005943');

INSERT INTO schema_migrations (version) VALUES ('20130619002830');

INSERT INTO schema_migrations (version) VALUES ('20130621223520');

INSERT INTO schema_migrations (version) VALUES ('20130625163103');

INSERT INTO schema_migrations (version) VALUES ('20130713201916');

INSERT INTO schema_migrations (version) VALUES ('20130714210748');

INSERT INTO schema_migrations (version) VALUES ('20130717150737');

INSERT INTO schema_migrations (version) VALUES ('20130723172207');

INSERT INTO schema_migrations (version) VALUES ('20130909161125');

INSERT INTO schema_migrations (version) VALUES ('20130912003743');

INSERT INTO schema_migrations (version) VALUES ('20130916172858');

INSERT INTO schema_migrations (version) VALUES ('20130916173041');

INSERT INTO schema_migrations (version) VALUES ('20130918192935');

INSERT INTO schema_migrations (version) VALUES ('20130918225446');

INSERT INTO schema_migrations (version) VALUES ('20130924190444');

INSERT INTO schema_migrations (version) VALUES ('20130925161132');

INSERT INTO schema_migrations (version) VALUES ('20130926192707');

INSERT INTO schema_migrations (version) VALUES ('20130926215014');

INSERT INTO schema_migrations (version) VALUES ('20130926215420');

INSERT INTO schema_migrations (version) VALUES ('20130926221414');

INSERT INTO schema_migrations (version) VALUES ('20130927170839');

INSERT INTO schema_migrations (version) VALUES ('20130930182546');

INSERT INTO schema_migrations (version) VALUES ('20130930190641');

INSERT INTO schema_migrations (version) VALUES ('20131002004641');

INSERT INTO schema_migrations (version) VALUES ('20131002164449');

INSERT INTO schema_migrations (version) VALUES ('20131003161836');

INSERT INTO schema_migrations (version) VALUES ('20131003184552');

INSERT INTO schema_migrations (version) VALUES ('20131004144220');

INSERT INTO schema_migrations (version) VALUES ('20131007015724');

INSERT INTO schema_migrations (version) VALUES ('20131007182256');

INSERT INTO schema_migrations (version) VALUES ('20131007223847');

INSERT INTO schema_migrations (version) VALUES ('20131008175447');

INSERT INTO schema_migrations (version) VALUES ('20131008213344');

INSERT INTO schema_migrations (version) VALUES ('20131009185103');

INSERT INTO schema_migrations (version) VALUES ('20131009190247');

INSERT INTO schema_migrations (version) VALUES ('20131010053502');

INSERT INTO schema_migrations (version) VALUES ('20131010194200');

INSERT INTO schema_migrations (version) VALUES ('20131011162000');

INSERT INTO schema_migrations (version) VALUES ('20131011184338');

INSERT INTO schema_migrations (version) VALUES ('20131014194612');

INSERT INTO schema_migrations (version) VALUES ('20131015183918');

INSERT INTO schema_migrations (version) VALUES ('20131016174540');

INSERT INTO schema_migrations (version) VALUES ('20131017150735');

INSERT INTO schema_migrations (version) VALUES ('20131017160756');

INSERT INTO schema_migrations (version) VALUES ('20131017201435');

INSERT INTO schema_migrations (version) VALUES ('20131018030838');

INSERT INTO schema_migrations (version) VALUES ('20131020212347');

INSERT INTO schema_migrations (version) VALUES ('20131020212504');

INSERT INTO schema_migrations (version) VALUES ('20131021185657');

INSERT INTO schema_migrations (version) VALUES ('20131021230028');

INSERT INTO schema_migrations (version) VALUES ('20131022022052');

INSERT INTO schema_migrations (version) VALUES ('20131022041731');

INSERT INTO schema_migrations (version) VALUES ('20131023221505');

INSERT INTO schema_migrations (version) VALUES ('20131027230811');

INSERT INTO schema_migrations (version) VALUES ('20131027232332');

INSERT INTO schema_migrations (version) VALUES ('20131028163019');

INSERT INTO schema_migrations (version) VALUES ('20131031051123');

INSERT INTO schema_migrations (version) VALUES ('20131031170750');

INSERT INTO schema_migrations (version) VALUES ('20131106204241');

INSERT INTO schema_migrations (version) VALUES ('20131119184509');

INSERT INTO schema_migrations (version) VALUES ('20131119213009');

INSERT INTO schema_migrations (version) VALUES ('20131119234551');

INSERT INTO schema_migrations (version) VALUES ('20131126181005');

INSERT INTO schema_migrations (version) VALUES ('20131210191238');

INSERT INTO schema_migrations (version) VALUES ('20131217221431');

INSERT INTO schema_migrations (version) VALUES ('20131227085944');

INSERT INTO schema_migrations (version) VALUES ('20140123170446');

INSERT INTO schema_migrations (version) VALUES ('20140123192615');

INSERT INTO schema_migrations (version) VALUES ('20140204172553');

INSERT INTO schema_migrations (version) VALUES ('20140206213023');

INSERT INTO schema_migrations (version) VALUES ('20140207175151');

INSERT INTO schema_migrations (version) VALUES ('20140210203055');

INSERT INTO schema_migrations (version) VALUES ('20140213192518');

INSERT INTO schema_migrations (version) VALUES ('20140219180722');

INSERT INTO schema_migrations (version) VALUES ('20140221003649');

INSERT INTO schema_migrations (version) VALUES ('20140306005831');

INSERT INTO schema_migrations (version) VALUES ('20140318174815');

INSERT INTO schema_migrations (version) VALUES ('20140331173835');

INSERT INTO schema_migrations (version) VALUES ('20140407195724');

INSERT INTO schema_migrations (version) VALUES ('20140407212345');

INSERT INTO schema_migrations (version) VALUES ('20140410132401');

INSERT INTO schema_migrations (version) VALUES ('20140410161611');

INSERT INTO schema_migrations (version) VALUES ('20140410191213');

INSERT INTO schema_migrations (version) VALUES ('20140410205410');

INSERT INTO schema_migrations (version) VALUES ('20140411142102');

INSERT INTO schema_migrations (version) VALUES ('20140411205325');

INSERT INTO schema_migrations (version) VALUES ('20140414192550');

INSERT INTO schema_migrations (version) VALUES ('20140417140933');

INSERT INTO schema_migrations (version) VALUES ('20140428203822');

INSERT INTO schema_migrations (version) VALUES ('20140429144029');

INSERT INTO schema_migrations (version) VALUES ('20140505174356');

INSERT INTO schema_migrations (version) VALUES ('20140507000330');

INSERT INTO schema_migrations (version) VALUES ('20140520140817');

INSERT INTO schema_migrations (version) VALUES ('20140603163708');

INSERT INTO schema_migrations (version) VALUES ('20140605173747');

INSERT INTO schema_migrations (version) VALUES ('20140606165728');

INSERT INTO schema_migrations (version) VALUES ('20140701184757');

INSERT INTO schema_migrations (version) VALUES ('20140702184622');

INSERT INTO schema_migrations (version) VALUES ('20140703144541');

INSERT INTO schema_migrations (version) VALUES ('20140708175508');

INSERT INTO schema_migrations (version) VALUES ('20140711184807');

INSERT INTO schema_migrations (version) VALUES ('20140722174919');

INSERT INTO schema_migrations (version) VALUES ('20140728191933');

INSERT INTO schema_migrations (version) VALUES ('20140729162740');

INSERT INTO schema_migrations (version) VALUES ('20140801150537');

INSERT INTO schema_migrations (version) VALUES ('20140804161504');

INSERT INTO schema_migrations (version) VALUES ('20140905031549');

INSERT INTO schema_migrations (version) VALUES ('20140909191631');

INSERT INTO schema_migrations (version) VALUES ('20140912163522');

INSERT INTO schema_migrations (version) VALUES ('20140912194642');

INSERT INTO schema_migrations (version) VALUES ('20140916162714');

INSERT INTO schema_migrations (version) VALUES ('20140917145416');

INSERT INTO schema_migrations (version) VALUES ('20140922170030');

INSERT INTO schema_migrations (version) VALUES ('20140930193425');

INSERT INTO schema_migrations (version) VALUES ('20140930203020');

INSERT INTO schema_migrations (version) VALUES ('20141001173504');

INSERT INTO schema_migrations (version) VALUES ('20141001183658');

INSERT INTO schema_migrations (version) VALUES ('20141029152449');

INSERT INTO schema_migrations (version) VALUES ('20141031190206');

INSERT INTO schema_migrations (version) VALUES ('20141112234624');

INSERT INTO schema_migrations (version) VALUES ('20141119153655');

INSERT INTO schema_migrations (version) VALUES ('20141124200327');

INSERT INTO schema_migrations (version) VALUES ('20141125170243');

INSERT INTO schema_migrations (version) VALUES ('20141201195259');

INSERT INTO schema_migrations (version) VALUES ('20141208002728');

INSERT INTO schema_migrations (version) VALUES ('20141210203237');

INSERT INTO schema_migrations (version) VALUES ('20150106201450');

INSERT INTO schema_migrations (version) VALUES ('20150112203945');

INSERT INTO schema_migrations (version) VALUES ('20150205192230');

INSERT INTO schema_migrations (version) VALUES ('20150205192745');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('23');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('25');

INSERT INTO schema_migrations (version) VALUES ('26');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('9');