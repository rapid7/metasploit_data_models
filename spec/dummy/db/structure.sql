SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_keys (
    id integer NOT NULL,
    token text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: api_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.api_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.api_keys_id_seq OWNED BY public.api_keys.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: async_callbacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.async_callbacks (
    id integer NOT NULL,
    uuid character varying NOT NULL,
    "timestamp" integer NOT NULL,
    listener_uri character varying,
    target_host character varying,
    target_port character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: async_callbacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.async_callbacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: async_callbacks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.async_callbacks_id_seq OWNED BY public.async_callbacks.id;


--
-- Name: automatic_exploitation_match_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automatic_exploitation_match_results (
    id integer NOT NULL,
    match_id integer,
    run_id integer,
    state character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: automatic_exploitation_match_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.automatic_exploitation_match_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: automatic_exploitation_match_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.automatic_exploitation_match_results_id_seq OWNED BY public.automatic_exploitation_match_results.id;


--
-- Name: automatic_exploitation_match_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automatic_exploitation_match_sets (
    id integer NOT NULL,
    workspace_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: automatic_exploitation_match_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.automatic_exploitation_match_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: automatic_exploitation_match_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.automatic_exploitation_match_sets_id_seq OWNED BY public.automatic_exploitation_match_sets.id;


--
-- Name: automatic_exploitation_matches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automatic_exploitation_matches (
    id integer NOT NULL,
    module_detail_id integer,
    state character varying,
    nexpose_data_vulnerability_definition_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    match_set_id integer,
    matchable_type character varying,
    matchable_id integer,
    module_fullname text
);


--
-- Name: automatic_exploitation_matches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.automatic_exploitation_matches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: automatic_exploitation_matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.automatic_exploitation_matches_id_seq OWNED BY public.automatic_exploitation_matches.id;


--
-- Name: automatic_exploitation_runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automatic_exploitation_runs (
    id integer NOT NULL,
    workspace_id integer,
    user_id integer,
    match_set_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: automatic_exploitation_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.automatic_exploitation_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: automatic_exploitation_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.automatic_exploitation_runs_id_seq OWNED BY public.automatic_exploitation_runs.id;


--
-- Name: clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clients (
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

CREATE SEQUENCE public.clients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.clients_id_seq OWNED BY public.clients.id;


--
-- Name: creds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.creds (
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
    source_type character varying
);


--
-- Name: creds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.creds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: creds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.creds_id_seq OWNED BY public.creds.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id integer NOT NULL,
    workspace_id integer,
    host_id integer,
    created_at timestamp without time zone,
    name character varying,
    updated_at timestamp without time zone,
    critical boolean,
    seen boolean,
    username character varying,
    info text
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: exploit_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exploit_attempts (
    id integer NOT NULL,
    host_id integer,
    service_id integer,
    vuln_id integer,
    attempted_at timestamp without time zone,
    exploited boolean,
    fail_reason character varying,
    username character varying,
    module text,
    session_id integer,
    loot_id integer,
    port integer,
    proto character varying,
    fail_detail text
);


--
-- Name: exploit_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exploit_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exploit_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exploit_attempts_id_seq OWNED BY public.exploit_attempts.id;


--
-- Name: exploited_hosts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exploited_hosts (
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

CREATE SEQUENCE public.exploited_hosts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exploited_hosts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exploited_hosts_id_seq OWNED BY public.exploited_hosts.id;


--
-- Name: host_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.host_details (
    id integer NOT NULL,
    host_id integer,
    nx_console_id integer,
    nx_device_id integer,
    src character varying,
    nx_site_name character varying,
    nx_site_importance character varying,
    nx_scan_template character varying,
    nx_risk_score double precision
);


--
-- Name: host_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.host_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: host_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.host_details_id_seq OWNED BY public.host_details.id;


--
-- Name: hosts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hosts (
    id integer NOT NULL,
    created_at timestamp without time zone,
    address inet NOT NULL,
    mac character varying,
    comm character varying,
    name character varying,
    state character varying,
    os_name character varying,
    os_flavor character varying,
    os_sp character varying,
    os_lang character varying,
    arch character varying,
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
    detected_arch character varying,
    os_family character varying
);


--
-- Name: hosts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hosts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hosts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hosts_id_seq OWNED BY public.hosts.id;


--
-- Name: hosts_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hosts_tags (
    host_id integer,
    tag_id integer,
    id integer NOT NULL
);


--
-- Name: hosts_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hosts_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hosts_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hosts_tags_id_seq OWNED BY public.hosts_tags.id;


--
-- Name: listeners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.listeners (
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

CREATE SEQUENCE public.listeners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: listeners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.listeners_id_seq OWNED BY public.listeners.id;


--
-- Name: loots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.loots (
    id integer NOT NULL,
    workspace_id integer DEFAULT 1 NOT NULL,
    host_id integer,
    service_id integer,
    ltype character varying(512),
    path character varying(1024),
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    content_type character varying,
    name text,
    info text,
    module_run_id integer
);


--
-- Name: loots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.loots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: loots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.loots_id_seq OWNED BY public.loots.id;


--
-- Name: macros; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.macros (
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

CREATE SEQUENCE public.macros_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: macros_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.macros_id_seq OWNED BY public.macros.id;


--
-- Name: mod_refs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mod_refs (
    id integer NOT NULL,
    module character varying(1024),
    mtype character varying(128),
    ref text
);


--
-- Name: mod_refs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mod_refs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mod_refs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mod_refs_id_seq OWNED BY public.mod_refs.id;


--
-- Name: module_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.module_actions (
    id integer NOT NULL,
    detail_id integer,
    name text
);


--
-- Name: module_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.module_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: module_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.module_actions_id_seq OWNED BY public.module_actions.id;


--
-- Name: module_archs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.module_archs (
    id integer NOT NULL,
    detail_id integer,
    name text
);


--
-- Name: module_archs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.module_archs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: module_archs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.module_archs_id_seq OWNED BY public.module_archs.id;


--
-- Name: module_authors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.module_authors (
    id integer NOT NULL,
    detail_id integer,
    name text,
    email text
);


--
-- Name: module_authors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.module_authors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: module_authors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.module_authors_id_seq OWNED BY public.module_authors.id;


--
-- Name: module_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.module_details (
    id integer NOT NULL,
    mtime timestamp without time zone,
    file text,
    mtype character varying,
    refname text,
    fullname text,
    name text,
    rank integer,
    description text,
    license character varying,
    privileged boolean,
    disclosure_date timestamp without time zone,
    default_target integer,
    default_action text,
    stance character varying,
    ready boolean
);


--
-- Name: module_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.module_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: module_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.module_details_id_seq OWNED BY public.module_details.id;


--
-- Name: module_mixins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.module_mixins (
    id integer NOT NULL,
    detail_id integer,
    name text
);


--
-- Name: module_mixins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.module_mixins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: module_mixins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.module_mixins_id_seq OWNED BY public.module_mixins.id;


--
-- Name: module_platforms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.module_platforms (
    id integer NOT NULL,
    detail_id integer,
    name text
);


--
-- Name: module_platforms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.module_platforms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: module_platforms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.module_platforms_id_seq OWNED BY public.module_platforms.id;


--
-- Name: module_refs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.module_refs (
    id integer NOT NULL,
    detail_id integer,
    name text
);


--
-- Name: module_refs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.module_refs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: module_refs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.module_refs_id_seq OWNED BY public.module_refs.id;


--
-- Name: module_runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.module_runs (
    id integer NOT NULL,
    attempted_at timestamp without time zone,
    fail_detail text,
    fail_reason character varying,
    module_fullname text,
    port integer,
    proto character varying,
    session_id integer,
    status character varying,
    trackable_id integer,
    trackable_type character varying,
    user_id integer,
    username character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: module_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.module_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: module_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.module_runs_id_seq OWNED BY public.module_runs.id;


--
-- Name: module_targets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.module_targets (
    id integer NOT NULL,
    detail_id integer,
    index integer,
    name text
);


--
-- Name: module_targets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.module_targets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: module_targets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.module_targets_id_seq OWNED BY public.module_targets.id;


--
-- Name: nexpose_consoles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nexpose_consoles (
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

CREATE SEQUENCE public.nexpose_consoles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nexpose_consoles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nexpose_consoles_id_seq OWNED BY public.nexpose_consoles.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id integer NOT NULL,
    created_at timestamp without time zone,
    ntype character varying(512),
    workspace_id integer DEFAULT 1 NOT NULL,
    service_id integer,
    host_id integer,
    updated_at timestamp without time zone,
    critical boolean,
    seen boolean,
    data text,
    vuln_id integer
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notes_id_seq OWNED BY public.notes.id;


--
-- Name: payloads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payloads (
    id integer NOT NULL,
    name character varying,
    uuid character varying,
    uuid_mask integer,
    "timestamp" integer,
    arch character varying,
    platform character varying,
    urls character varying,
    description character varying,
    raw_payload character varying,
    raw_payload_hash character varying,
    build_status character varying,
    build_opts character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: payloads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payloads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payloads_id_seq OWNED BY public.payloads.id;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
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

CREATE SEQUENCE public.profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.profiles_id_seq OWNED BY public.profiles.id;


--
-- Name: refs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refs (
    id integer NOT NULL,
    ref_id integer,
    created_at timestamp without time zone,
    name character varying(512),
    updated_at timestamp without time zone
);


--
-- Name: refs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.refs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.refs_id_seq OWNED BY public.refs.id;


--
-- Name: report_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_templates (
    id integer NOT NULL,
    workspace_id integer DEFAULT 1 NOT NULL,
    created_by character varying,
    path character varying(1024),
    name text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: report_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.report_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: report_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.report_templates_id_seq OWNED BY public.report_templates.id;


--
-- Name: reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reports (
    id integer NOT NULL,
    workspace_id integer DEFAULT 1 NOT NULL,
    created_by character varying,
    rtype character varying,
    path character varying(1024),
    options text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    downloaded_at timestamp without time zone,
    task_id integer,
    name character varying(63)
);


--
-- Name: reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reports_id_seq OWNED BY public.reports.id;


--
-- Name: routes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.routes (
    id integer NOT NULL,
    session_id integer,
    subnet character varying,
    netmask character varying
);


--
-- Name: routes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.routes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: routes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.routes_id_seq OWNED BY public.routes.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.services (
    id integer NOT NULL,
    host_id integer,
    created_at timestamp without time zone,
    port integer NOT NULL,
    proto character varying(16) NOT NULL,
    state character varying,
    name character varying,
    updated_at timestamp without time zone,
    info text
);


--
-- Name: services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.services_id_seq OWNED BY public.services.id;


--
-- Name: session_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.session_events (
    id integer NOT NULL,
    session_id integer,
    etype character varying,
    command bytea,
    output bytea,
    remote_path character varying,
    local_path character varying,
    created_at timestamp without time zone
);


--
-- Name: session_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.session_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: session_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.session_events_id_seq OWNED BY public.session_events.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id integer NOT NULL,
    host_id integer,
    stype character varying,
    via_exploit character varying,
    via_payload character varying,
    "desc" character varying,
    port integer,
    platform character varying,
    datastore text,
    opened_at timestamp without time zone NOT NULL,
    closed_at timestamp without time zone,
    close_reason character varying,
    local_id integer,
    last_seen timestamp without time zone,
    module_run_id integer
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
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

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: task_creds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_creds (
    id integer NOT NULL,
    task_id integer NOT NULL,
    cred_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: task_creds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_creds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_creds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_creds_id_seq OWNED BY public.task_creds.id;


--
-- Name: task_hosts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_hosts (
    id integer NOT NULL,
    task_id integer NOT NULL,
    host_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: task_hosts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_hosts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_hosts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_hosts_id_seq OWNED BY public.task_hosts.id;


--
-- Name: task_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_services (
    id integer NOT NULL,
    task_id integer NOT NULL,
    service_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: task_services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_services_id_seq OWNED BY public.task_services.id;


--
-- Name: task_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_sessions (
    id integer NOT NULL,
    task_id integer NOT NULL,
    session_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: task_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_sessions_id_seq OWNED BY public.task_sessions.id;


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tasks (
    id integer NOT NULL,
    workspace_id integer DEFAULT 1 NOT NULL,
    created_by character varying,
    module character varying,
    completed_at timestamp without time zone,
    path character varying(1024),
    info character varying,
    description character varying,
    progress integer,
    options text,
    error text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    result text,
    module_uuid character varying(8),
    settings bytea
);


--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tasks_id_seq OWNED BY public.tasks.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying,
    crypted_password character varying,
    password_salt character varying,
    persistence_token character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    fullname character varying,
    email character varying,
    phone character varying,
    company character varying,
    prefs character varying(524288),
    admin boolean DEFAULT true NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vuln_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vuln_attempts (
    id integer NOT NULL,
    vuln_id integer,
    attempted_at timestamp without time zone,
    exploited boolean,
    fail_reason character varying,
    username character varying,
    module text,
    session_id integer,
    loot_id integer,
    fail_detail text
);


--
-- Name: vuln_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vuln_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vuln_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vuln_attempts_id_seq OWNED BY public.vuln_attempts.id;


--
-- Name: vuln_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vuln_details (
    id integer NOT NULL,
    vuln_id integer,
    cvss_score double precision,
    cvss_vector character varying,
    title character varying,
    description text,
    solution text,
    proof bytea,
    nx_console_id integer,
    nx_device_id integer,
    nx_vuln_id character varying,
    nx_severity double precision,
    nx_pci_severity double precision,
    nx_published timestamp without time zone,
    nx_added timestamp without time zone,
    nx_modified timestamp without time zone,
    nx_tags text,
    nx_vuln_status text,
    nx_proof_key text,
    src character varying,
    nx_scan_id integer,
    nx_vulnerable_since timestamp without time zone,
    nx_pci_compliance_status character varying
);


--
-- Name: vuln_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vuln_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vuln_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vuln_details_id_seq OWNED BY public.vuln_details.id;


--
-- Name: vulns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vulns (
    id integer NOT NULL,
    host_id integer,
    service_id integer,
    created_at timestamp without time zone,
    name character varying,
    updated_at timestamp without time zone,
    info character varying(65536),
    exploited_at timestamp without time zone,
    vuln_detail_count integer DEFAULT 0,
    vuln_attempt_count integer DEFAULT 0,
    origin_id integer,
    origin_type character varying
);


--
-- Name: vulns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vulns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vulns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vulns_id_seq OWNED BY public.vulns.id;


--
-- Name: vulns_refs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vulns_refs (
    ref_id integer,
    vuln_id integer,
    id integer NOT NULL
);


--
-- Name: vulns_refs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vulns_refs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vulns_refs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vulns_refs_id_seq OWNED BY public.vulns_refs.id;


--
-- Name: web_forms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.web_forms (
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

CREATE SEQUENCE public.web_forms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_forms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.web_forms_id_seq OWNED BY public.web_forms.id;


--
-- Name: web_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.web_pages (
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

CREATE SEQUENCE public.web_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.web_pages_id_seq OWNED BY public.web_pages.id;


--
-- Name: web_sites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.web_sites (
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

CREATE SEQUENCE public.web_sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.web_sites_id_seq OWNED BY public.web_sites.id;


--
-- Name: web_vulns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.web_vulns (
    id integer NOT NULL,
    web_site_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    path text NOT NULL,
    method character varying(1024) NOT NULL,
    params text,
    pname text,
    risk integer NOT NULL,
    name character varying(1024) NOT NULL,
    query text,
    category text NOT NULL,
    confidence integer NOT NULL,
    description text,
    blame text,
    request bytea,
    proof bytea NOT NULL,
    owner character varying,
    payload text
);


--
-- Name: web_vulns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.web_vulns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_vulns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.web_vulns_id_seq OWNED BY public.web_vulns.id;


--
-- Name: wmap_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wmap_requests (
    id integer NOT NULL,
    host character varying,
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

CREATE SEQUENCE public.wmap_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wmap_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wmap_requests_id_seq OWNED BY public.wmap_requests.id;


--
-- Name: wmap_targets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wmap_targets (
    id integer NOT NULL,
    host character varying,
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

CREATE SEQUENCE public.wmap_targets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wmap_targets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wmap_targets_id_seq OWNED BY public.wmap_targets.id;


--
-- Name: workspace_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_members (
    workspace_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: workspaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspaces (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    boundary character varying(4096),
    description character varying(4096),
    owner_id integer,
    limit_to_network boolean DEFAULT false NOT NULL,
    import_fingerprint boolean DEFAULT false
);


--
-- Name: workspaces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.workspaces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workspaces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workspaces_id_seq OWNED BY public.workspaces.id;


--
-- Name: api_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys ALTER COLUMN id SET DEFAULT nextval('public.api_keys_id_seq'::regclass);


--
-- Name: async_callbacks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.async_callbacks ALTER COLUMN id SET DEFAULT nextval('public.async_callbacks_id_seq'::regclass);


--
-- Name: automatic_exploitation_match_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automatic_exploitation_match_results ALTER COLUMN id SET DEFAULT nextval('public.automatic_exploitation_match_results_id_seq'::regclass);


--
-- Name: automatic_exploitation_match_sets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automatic_exploitation_match_sets ALTER COLUMN id SET DEFAULT nextval('public.automatic_exploitation_match_sets_id_seq'::regclass);


--
-- Name: automatic_exploitation_matches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automatic_exploitation_matches ALTER COLUMN id SET DEFAULT nextval('public.automatic_exploitation_matches_id_seq'::regclass);


--
-- Name: automatic_exploitation_runs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automatic_exploitation_runs ALTER COLUMN id SET DEFAULT nextval('public.automatic_exploitation_runs_id_seq'::regclass);


--
-- Name: clients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients ALTER COLUMN id SET DEFAULT nextval('public.clients_id_seq'::regclass);


--
-- Name: creds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.creds ALTER COLUMN id SET DEFAULT nextval('public.creds_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: exploit_attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exploit_attempts ALTER COLUMN id SET DEFAULT nextval('public.exploit_attempts_id_seq'::regclass);


--
-- Name: exploited_hosts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exploited_hosts ALTER COLUMN id SET DEFAULT nextval('public.exploited_hosts_id_seq'::regclass);


--
-- Name: host_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.host_details ALTER COLUMN id SET DEFAULT nextval('public.host_details_id_seq'::regclass);


--
-- Name: hosts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hosts ALTER COLUMN id SET DEFAULT nextval('public.hosts_id_seq'::regclass);


--
-- Name: hosts_tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hosts_tags ALTER COLUMN id SET DEFAULT nextval('public.hosts_tags_id_seq'::regclass);


--
-- Name: listeners id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.listeners ALTER COLUMN id SET DEFAULT nextval('public.listeners_id_seq'::regclass);


--
-- Name: loots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loots ALTER COLUMN id SET DEFAULT nextval('public.loots_id_seq'::regclass);


--
-- Name: macros id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.macros ALTER COLUMN id SET DEFAULT nextval('public.macros_id_seq'::regclass);


--
-- Name: mod_refs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_refs ALTER COLUMN id SET DEFAULT nextval('public.mod_refs_id_seq'::regclass);


--
-- Name: module_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_actions ALTER COLUMN id SET DEFAULT nextval('public.module_actions_id_seq'::regclass);


--
-- Name: module_archs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_archs ALTER COLUMN id SET DEFAULT nextval('public.module_archs_id_seq'::regclass);


--
-- Name: module_authors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_authors ALTER COLUMN id SET DEFAULT nextval('public.module_authors_id_seq'::regclass);


--
-- Name: module_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_details ALTER COLUMN id SET DEFAULT nextval('public.module_details_id_seq'::regclass);


--
-- Name: module_mixins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_mixins ALTER COLUMN id SET DEFAULT nextval('public.module_mixins_id_seq'::regclass);


--
-- Name: module_platforms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_platforms ALTER COLUMN id SET DEFAULT nextval('public.module_platforms_id_seq'::regclass);


--
-- Name: module_refs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_refs ALTER COLUMN id SET DEFAULT nextval('public.module_refs_id_seq'::regclass);


--
-- Name: module_runs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_runs ALTER COLUMN id SET DEFAULT nextval('public.module_runs_id_seq'::regclass);


--
-- Name: module_targets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_targets ALTER COLUMN id SET DEFAULT nextval('public.module_targets_id_seq'::regclass);


--
-- Name: nexpose_consoles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nexpose_consoles ALTER COLUMN id SET DEFAULT nextval('public.nexpose_consoles_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Name: payloads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payloads ALTER COLUMN id SET DEFAULT nextval('public.payloads_id_seq'::regclass);


--
-- Name: profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles ALTER COLUMN id SET DEFAULT nextval('public.profiles_id_seq'::regclass);


--
-- Name: refs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refs ALTER COLUMN id SET DEFAULT nextval('public.refs_id_seq'::regclass);


--
-- Name: report_templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_templates ALTER COLUMN id SET DEFAULT nextval('public.report_templates_id_seq'::regclass);


--
-- Name: reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports ALTER COLUMN id SET DEFAULT nextval('public.reports_id_seq'::regclass);


--
-- Name: routes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.routes ALTER COLUMN id SET DEFAULT nextval('public.routes_id_seq'::regclass);


--
-- Name: services id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services ALTER COLUMN id SET DEFAULT nextval('public.services_id_seq'::regclass);


--
-- Name: session_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_events ALTER COLUMN id SET DEFAULT nextval('public.session_events_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: task_creds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_creds ALTER COLUMN id SET DEFAULT nextval('public.task_creds_id_seq'::regclass);


--
-- Name: task_hosts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_hosts ALTER COLUMN id SET DEFAULT nextval('public.task_hosts_id_seq'::regclass);


--
-- Name: task_services id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_services ALTER COLUMN id SET DEFAULT nextval('public.task_services_id_seq'::regclass);


--
-- Name: task_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_sessions ALTER COLUMN id SET DEFAULT nextval('public.task_sessions_id_seq'::regclass);


--
-- Name: tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks ALTER COLUMN id SET DEFAULT nextval('public.tasks_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: vuln_attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vuln_attempts ALTER COLUMN id SET DEFAULT nextval('public.vuln_attempts_id_seq'::regclass);


--
-- Name: vuln_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vuln_details ALTER COLUMN id SET DEFAULT nextval('public.vuln_details_id_seq'::regclass);


--
-- Name: vulns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vulns ALTER COLUMN id SET DEFAULT nextval('public.vulns_id_seq'::regclass);


--
-- Name: vulns_refs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vulns_refs ALTER COLUMN id SET DEFAULT nextval('public.vulns_refs_id_seq'::regclass);


--
-- Name: web_forms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_forms ALTER COLUMN id SET DEFAULT nextval('public.web_forms_id_seq'::regclass);


--
-- Name: web_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_pages ALTER COLUMN id SET DEFAULT nextval('public.web_pages_id_seq'::regclass);


--
-- Name: web_sites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_sites ALTER COLUMN id SET DEFAULT nextval('public.web_sites_id_seq'::regclass);


--
-- Name: web_vulns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_vulns ALTER COLUMN id SET DEFAULT nextval('public.web_vulns_id_seq'::regclass);


--
-- Name: wmap_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wmap_requests ALTER COLUMN id SET DEFAULT nextval('public.wmap_requests_id_seq'::regclass);


--
-- Name: wmap_targets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wmap_targets ALTER COLUMN id SET DEFAULT nextval('public.wmap_targets_id_seq'::regclass);


--
-- Name: workspaces id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces ALTER COLUMN id SET DEFAULT nextval('public.workspaces_id_seq'::regclass);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: async_callbacks async_callbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.async_callbacks
    ADD CONSTRAINT async_callbacks_pkey PRIMARY KEY (id);


--
-- Name: automatic_exploitation_match_results automatic_exploitation_match_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automatic_exploitation_match_results
    ADD CONSTRAINT automatic_exploitation_match_results_pkey PRIMARY KEY (id);


--
-- Name: automatic_exploitation_match_sets automatic_exploitation_match_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automatic_exploitation_match_sets
    ADD CONSTRAINT automatic_exploitation_match_sets_pkey PRIMARY KEY (id);


--
-- Name: automatic_exploitation_matches automatic_exploitation_matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automatic_exploitation_matches
    ADD CONSTRAINT automatic_exploitation_matches_pkey PRIMARY KEY (id);


--
-- Name: automatic_exploitation_runs automatic_exploitation_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automatic_exploitation_runs
    ADD CONSTRAINT automatic_exploitation_runs_pkey PRIMARY KEY (id);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: creds creds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.creds
    ADD CONSTRAINT creds_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: exploit_attempts exploit_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exploit_attempts
    ADD CONSTRAINT exploit_attempts_pkey PRIMARY KEY (id);


--
-- Name: exploited_hosts exploited_hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exploited_hosts
    ADD CONSTRAINT exploited_hosts_pkey PRIMARY KEY (id);


--
-- Name: host_details host_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.host_details
    ADD CONSTRAINT host_details_pkey PRIMARY KEY (id);


--
-- Name: hosts hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hosts
    ADD CONSTRAINT hosts_pkey PRIMARY KEY (id);


--
-- Name: hosts_tags hosts_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hosts_tags
    ADD CONSTRAINT hosts_tags_pkey PRIMARY KEY (id);


--
-- Name: listeners listeners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.listeners
    ADD CONSTRAINT listeners_pkey PRIMARY KEY (id);


--
-- Name: loots loots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loots
    ADD CONSTRAINT loots_pkey PRIMARY KEY (id);


--
-- Name: macros macros_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.macros
    ADD CONSTRAINT macros_pkey PRIMARY KEY (id);


--
-- Name: mod_refs mod_refs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_refs
    ADD CONSTRAINT mod_refs_pkey PRIMARY KEY (id);


--
-- Name: module_actions module_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_actions
    ADD CONSTRAINT module_actions_pkey PRIMARY KEY (id);


--
-- Name: module_archs module_archs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_archs
    ADD CONSTRAINT module_archs_pkey PRIMARY KEY (id);


--
-- Name: module_authors module_authors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_authors
    ADD CONSTRAINT module_authors_pkey PRIMARY KEY (id);


--
-- Name: module_details module_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_details
    ADD CONSTRAINT module_details_pkey PRIMARY KEY (id);


--
-- Name: module_mixins module_mixins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_mixins
    ADD CONSTRAINT module_mixins_pkey PRIMARY KEY (id);


--
-- Name: module_platforms module_platforms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_platforms
    ADD CONSTRAINT module_platforms_pkey PRIMARY KEY (id);


--
-- Name: module_refs module_refs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_refs
    ADD CONSTRAINT module_refs_pkey PRIMARY KEY (id);


--
-- Name: module_runs module_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_runs
    ADD CONSTRAINT module_runs_pkey PRIMARY KEY (id);


--
-- Name: module_targets module_targets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_targets
    ADD CONSTRAINT module_targets_pkey PRIMARY KEY (id);


--
-- Name: nexpose_consoles nexpose_consoles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nexpose_consoles
    ADD CONSTRAINT nexpose_consoles_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: payloads payloads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payloads
    ADD CONSTRAINT payloads_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: refs refs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refs
    ADD CONSTRAINT refs_pkey PRIMARY KEY (id);


--
-- Name: report_templates report_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_templates
    ADD CONSTRAINT report_templates_pkey PRIMARY KEY (id);


--
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- Name: routes routes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: session_events session_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_events
    ADD CONSTRAINT session_events_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: task_creds task_creds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_creds
    ADD CONSTRAINT task_creds_pkey PRIMARY KEY (id);


--
-- Name: task_hosts task_hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_hosts
    ADD CONSTRAINT task_hosts_pkey PRIMARY KEY (id);


--
-- Name: task_services task_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_services
    ADD CONSTRAINT task_services_pkey PRIMARY KEY (id);


--
-- Name: task_sessions task_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_sessions
    ADD CONSTRAINT task_sessions_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vuln_attempts vuln_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vuln_attempts
    ADD CONSTRAINT vuln_attempts_pkey PRIMARY KEY (id);


--
-- Name: vuln_details vuln_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vuln_details
    ADD CONSTRAINT vuln_details_pkey PRIMARY KEY (id);


--
-- Name: vulns vulns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vulns
    ADD CONSTRAINT vulns_pkey PRIMARY KEY (id);


--
-- Name: vulns_refs vulns_refs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vulns_refs
    ADD CONSTRAINT vulns_refs_pkey PRIMARY KEY (id);


--
-- Name: web_forms web_forms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_forms
    ADD CONSTRAINT web_forms_pkey PRIMARY KEY (id);


--
-- Name: web_pages web_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_pages
    ADD CONSTRAINT web_pages_pkey PRIMARY KEY (id);


--
-- Name: web_sites web_sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_sites
    ADD CONSTRAINT web_sites_pkey PRIMARY KEY (id);


--
-- Name: web_vulns web_vulns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_vulns
    ADD CONSTRAINT web_vulns_pkey PRIMARY KEY (id);


--
-- Name: wmap_requests wmap_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wmap_requests
    ADD CONSTRAINT wmap_requests_pkey PRIMARY KEY (id);


--
-- Name: wmap_targets wmap_targets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wmap_targets
    ADD CONSTRAINT wmap_targets_pkey PRIMARY KEY (id);


--
-- Name: workspaces workspaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_pkey PRIMARY KEY (id);


--
-- Name: index_automatic_exploitation_match_results_on_match_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_automatic_exploitation_match_results_on_match_id ON public.automatic_exploitation_match_results USING btree (match_id);


--
-- Name: index_automatic_exploitation_match_results_on_run_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_automatic_exploitation_match_results_on_run_id ON public.automatic_exploitation_match_results USING btree (run_id);


--
-- Name: index_automatic_exploitation_match_sets_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_automatic_exploitation_match_sets_on_user_id ON public.automatic_exploitation_match_sets USING btree (user_id);


--
-- Name: index_automatic_exploitation_match_sets_on_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_automatic_exploitation_match_sets_on_workspace_id ON public.automatic_exploitation_match_sets USING btree (workspace_id);


--
-- Name: index_automatic_exploitation_matches_on_module_detail_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_automatic_exploitation_matches_on_module_detail_id ON public.automatic_exploitation_matches USING btree (module_detail_id);


--
-- Name: index_automatic_exploitation_matches_on_module_fullname; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_automatic_exploitation_matches_on_module_fullname ON public.automatic_exploitation_matches USING btree (module_fullname);


--
-- Name: index_automatic_exploitation_runs_on_match_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_automatic_exploitation_runs_on_match_set_id ON public.automatic_exploitation_runs USING btree (match_set_id);


--
-- Name: index_automatic_exploitation_runs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_automatic_exploitation_runs_on_user_id ON public.automatic_exploitation_runs USING btree (user_id);


--
-- Name: index_automatic_exploitation_runs_on_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_automatic_exploitation_runs_on_workspace_id ON public.automatic_exploitation_runs USING btree (workspace_id);


--
-- Name: index_hosts_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hosts_on_name ON public.hosts USING btree (name);


--
-- Name: index_hosts_on_os_flavor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hosts_on_os_flavor ON public.hosts USING btree (os_flavor);


--
-- Name: index_hosts_on_os_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hosts_on_os_name ON public.hosts USING btree (os_name);


--
-- Name: index_hosts_on_purpose; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hosts_on_purpose ON public.hosts USING btree (purpose);


--
-- Name: index_hosts_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hosts_on_state ON public.hosts USING btree (state);


--
-- Name: index_hosts_on_workspace_id_and_address; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_hosts_on_workspace_id_and_address ON public.hosts USING btree (workspace_id, address);


--
-- Name: index_loots_on_module_run_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_loots_on_module_run_id ON public.loots USING btree (module_run_id);


--
-- Name: index_module_actions_on_detail_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_module_actions_on_detail_id ON public.module_actions USING btree (detail_id);


--
-- Name: index_module_archs_on_detail_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_module_archs_on_detail_id ON public.module_archs USING btree (detail_id);


--
-- Name: index_module_authors_on_detail_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_module_authors_on_detail_id ON public.module_authors USING btree (detail_id);


--
-- Name: index_module_details_on_description; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_module_details_on_description ON public.module_details USING btree (description);


--
-- Name: index_module_details_on_mtype; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_module_details_on_mtype ON public.module_details USING btree (mtype);


--
-- Name: index_module_details_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_module_details_on_name ON public.module_details USING btree (name);


--
-- Name: index_module_details_on_refname; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_module_details_on_refname ON public.module_details USING btree (refname);


--
-- Name: index_module_mixins_on_detail_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_module_mixins_on_detail_id ON public.module_mixins USING btree (detail_id);


--
-- Name: index_module_platforms_on_detail_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_module_platforms_on_detail_id ON public.module_platforms USING btree (detail_id);


--
-- Name: index_module_refs_on_detail_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_module_refs_on_detail_id ON public.module_refs USING btree (detail_id);


--
-- Name: index_module_refs_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_module_refs_on_name ON public.module_refs USING btree (name);


--
-- Name: index_module_runs_on_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_module_runs_on_session_id ON public.module_runs USING btree (session_id);


--
-- Name: index_module_runs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_module_runs_on_user_id ON public.module_runs USING btree (user_id);


--
-- Name: index_module_targets_on_detail_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_module_targets_on_detail_id ON public.module_targets USING btree (detail_id);


--
-- Name: index_notes_on_ntype; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_ntype ON public.notes USING btree (ntype);


--
-- Name: index_notes_on_vuln_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_vuln_id ON public.notes USING btree (vuln_id);


--
-- Name: index_refs_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_refs_on_name ON public.refs USING btree (name);


--
-- Name: index_services_on_host_id_and_port_and_proto; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_services_on_host_id_and_port_and_proto ON public.services USING btree (host_id, port, proto);


--
-- Name: index_services_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_services_on_name ON public.services USING btree (name);


--
-- Name: index_services_on_port; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_services_on_port ON public.services USING btree (port);


--
-- Name: index_services_on_proto; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_services_on_proto ON public.services USING btree (proto);


--
-- Name: index_services_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_services_on_state ON public.services USING btree (state);


--
-- Name: index_sessions_on_module_run_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_module_run_id ON public.sessions USING btree (module_run_id);


--
-- Name: index_vulns_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulns_on_name ON public.vulns USING btree (name);


--
-- Name: index_vulns_on_origin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulns_on_origin_id ON public.vulns USING btree (origin_id);


--
-- Name: index_web_forms_on_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_web_forms_on_path ON public.web_forms USING btree (path);


--
-- Name: index_web_pages_on_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_web_pages_on_path ON public.web_pages USING btree (path);


--
-- Name: index_web_pages_on_query; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_web_pages_on_query ON public.web_pages USING btree (query);


--
-- Name: index_web_sites_on_comments; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_web_sites_on_comments ON public.web_sites USING btree (comments);


--
-- Name: index_web_sites_on_options; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_web_sites_on_options ON public.web_sites USING btree (options);


--
-- Name: index_web_sites_on_vhost; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_web_sites_on_vhost ON public.web_sites USING btree (vhost);


--
-- Name: index_web_vulns_on_method; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_web_vulns_on_method ON public.web_vulns USING btree (method);


--
-- Name: index_web_vulns_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_web_vulns_on_name ON public.web_vulns USING btree (name);


--
-- Name: index_web_vulns_on_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_web_vulns_on_path ON public.web_vulns USING btree (path);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('0'),
('1'),
('10'),
('11'),
('12'),
('13'),
('14'),
('15'),
('16'),
('17'),
('18'),
('19'),
('2'),
('20'),
('20100819123300'),
('20100824151500'),
('20100908001428'),
('20100911122000'),
('20100916151530'),
('20100916175000'),
('20100920012100'),
('20100926214000'),
('20101001000000'),
('20101002000000'),
('20101007000000'),
('20101008111800'),
('20101009023300'),
('20101104135100'),
('20101203000000'),
('20101203000001'),
('20101206212033'),
('20110112154300'),
('20110204112800'),
('20110317144932'),
('20110414180600'),
('20110415175705'),
('20110422000000'),
('20110425095900'),
('20110513143900'),
('20110517160800'),
('20110527000000'),
('20110527000001'),
('20110606000001'),
('20110622000000'),
('20110624000001'),
('20110625000001'),
('20110630000001'),
('20110630000002'),
('20110717000001'),
('20110727163801'),
('20110730000001'),
('20110812000001'),
('20110922000000'),
('20110928101300'),
('20111011110000'),
('20111203000000'),
('20111204000000'),
('20111210000000'),
('20120126110000'),
('20120411173220'),
('20120601152442'),
('20120625000000'),
('20120625000001'),
('20120625000002'),
('20120625000003'),
('20120625000004'),
('20120625000005'),
('20120625000006'),
('20120625000007'),
('20120625000008'),
('20120718202805'),
('20130228214900'),
('20130412154159'),
('20130412171844'),
('20130412173121'),
('20130412173640'),
('20130412174254'),
('20130412174719'),
('20130412175040'),
('20130423211152'),
('20130430151353'),
('20130430162145'),
('20130510021637'),
('20130515164311'),
('20130515172727'),
('20130516204810'),
('20130522001343'),
('20130522032517'),
('20130522041110'),
('20130525015035'),
('20130525212420'),
('20130531144949'),
('20130604145732'),
('20130717150737'),
('20131002004641'),
('20131002164449'),
('20131008213344'),
('20131011184338'),
('20131017150735'),
('20131021185657'),
('20140905031549'),
('20150112203945'),
('20150205192745'),
('20150209195939'),
('20150212214222'),
('20150219173821'),
('20150219215039'),
('20150226151459'),
('20150312155312'),
('20150317145455'),
('20150326183742'),
('20150421211719'),
('20150514182921'),
('20160415153312'),
('20161004165612'),
('20161227212223'),
('20180904120211'),
('20190308134512'),
('20190507120211'),
('20200825000000'),
('21'),
('22'),
('23'),
('24'),
('25'),
('26'),
('3'),
('4'),
('5'),
('6'),
('7'),
('8'),
('9');


