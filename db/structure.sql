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
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: sourcepattern(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sourcepattern(src text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
               BEGIN
                 RETURN regexp_replace(src, '^[^/]*(//)?[^/]*.pixiv.net/img.*(/[^/]*/[^/]*)$', E'pixiv\\2');
               END;
             $_$;


--
-- Name: testprs_end(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.testprs_end(internal) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_end';


--
-- Name: testprs_getlexeme(internal, internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.testprs_getlexeme(internal, internal, internal) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_getlexeme';


--
-- Name: testprs_lextype(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.testprs_lextype(internal) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_lextype';


--
-- Name: testprs_start(internal, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.testprs_start(internal, integer) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_start';


--
-- Name: testparser; Type: TEXT SEARCH PARSER; Schema: public; Owner: -
--

CREATE TEXT SEARCH PARSER public.testparser (
    START = public.testprs_start,
    GETTOKEN = public.testprs_getlexeme,
    END = public.testprs_end,
    HEADLINE = prsd_headline,
    LEXTYPES = public.testprs_lextype );


--
-- Name: danbooru; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION public.danbooru (
    PARSER = public.testparser );

ALTER TEXT SEARCH CONFIGURATION public.danbooru
    ADD MAPPING FOR word WITH simple;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: advertisement_hits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.advertisement_hits (
    id integer NOT NULL,
    advertisement_id integer NOT NULL,
    ip_addr inet NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: advertisement_hits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.advertisement_hits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: advertisement_hits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.advertisement_hits_id_seq OWNED BY public.advertisement_hits.id;


--
-- Name: advertisements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.advertisements (
    id integer NOT NULL,
    referral_url text NOT NULL,
    ad_type character varying NOT NULL,
    status character varying NOT NULL,
    hit_count integer DEFAULT 0 NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    file_name character varying NOT NULL,
    is_work_safe boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: advertisements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.advertisements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: advertisements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.advertisements_id_seq OWNED BY public.advertisements.id;


--
-- Name: amazon_backups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.amazon_backups (
    id integer NOT NULL,
    last_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: amazon_backups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.amazon_backups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: amazon_backups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.amazon_backups_id_seq OWNED BY public.amazon_backups.id;


--
-- Name: anti_voters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.anti_voters (
    id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: anti_voters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.anti_voters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: anti_voters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.anti_voters_id_seq OWNED BY public.anti_voters.id;


--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_keys (
    id integer NOT NULL,
    user_id integer NOT NULL,
    key character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: api_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.api_keys_id_seq
    AS integer
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
-- Name: artist_commentaries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artist_commentaries (
    id integer NOT NULL,
    post_id integer NOT NULL,
    original_title text DEFAULT ''::text NOT NULL,
    original_description text DEFAULT ''::text NOT NULL,
    translated_title text DEFAULT ''::text NOT NULL,
    translated_description text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: artist_commentaries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artist_commentaries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_commentaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artist_commentaries_id_seq OWNED BY public.artist_commentaries.id;


--
-- Name: artist_commentary_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artist_commentary_versions (
    id integer NOT NULL,
    post_id integer NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    original_title text,
    original_description text,
    translated_title text,
    translated_description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: artist_commentary_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artist_commentary_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_commentary_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artist_commentary_versions_id_seq OWNED BY public.artist_commentary_versions.id;


--
-- Name: artist_urls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artist_urls (
    id integer NOT NULL,
    artist_id integer NOT NULL,
    url text NOT NULL,
    normalized_url text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    is_active boolean DEFAULT true NOT NULL
);


--
-- Name: artist_urls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artist_urls_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artist_urls_id_seq OWNED BY public.artist_urls.id;


--
-- Name: artist_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artist_versions (
    id integer NOT NULL,
    artist_id integer NOT NULL,
    name character varying NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    group_name character varying DEFAULT ''::character varying NOT NULL,
    is_banned boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    other_names text[] DEFAULT '{}'::text[] NOT NULL,
    urls text[] DEFAULT '{}'::text[] NOT NULL
);


--
-- Name: artist_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artist_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artist_versions_id_seq OWNED BY public.artist_versions.id;


--
-- Name: artists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artists (
    id integer NOT NULL,
    name character varying NOT NULL,
    creator_id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    is_banned boolean DEFAULT false NOT NULL,
    group_name character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    other_names text[] DEFAULT '{}'::text[] NOT NULL
);


--
-- Name: artists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artists_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artists_id_seq OWNED BY public.artists.id;


--
-- Name: bans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bans (
    id integer NOT NULL,
    user_id integer,
    reason text NOT NULL,
    banner_id integer NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: bans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bans_id_seq OWNED BY public.bans.id;


--
-- Name: bulk_update_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bulk_update_requests (
    id integer NOT NULL,
    user_id integer NOT NULL,
    forum_topic_id integer,
    script text NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    approver_id integer,
    forum_post_id integer,
    title text
);


--
-- Name: bulk_update_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bulk_update_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bulk_update_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bulk_update_requests_id_seq OWNED BY public.bulk_update_requests.id;


--
-- Name: comment_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comment_votes (
    id integer NOT NULL,
    comment_id integer NOT NULL,
    user_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: comment_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comment_votes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comment_votes_id_seq OWNED BY public.comment_votes.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    post_id integer NOT NULL,
    creator_id integer NOT NULL,
    body text NOT NULL,
    creator_ip_addr inet NOT NULL,
    body_index tsvector NOT NULL,
    score integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    updater_id integer,
    updater_ip_addr inet,
    do_not_bump_post boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    is_sticky boolean DEFAULT false NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    queue character varying
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delayed_jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;


--
-- Name: dmail_filters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dmail_filters (
    id integer NOT NULL,
    user_id integer NOT NULL,
    words text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: dmail_filters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dmail_filters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dmail_filters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dmail_filters_id_seq OWNED BY public.dmail_filters.id;


--
-- Name: dmails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dmails (
    id integer NOT NULL,
    owner_id integer NOT NULL,
    from_id integer NOT NULL,
    to_id integer NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    message_index tsvector NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_ip_addr inet NOT NULL,
    is_spam boolean DEFAULT false
);


--
-- Name: dmails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dmails_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dmails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dmails_id_seq OWNED BY public.dmails.id;


--
-- Name: email_blacklists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_blacklists (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    domain character varying NOT NULL,
    creator_id integer NOT NULL,
    reason character varying NOT NULL
);


--
-- Name: email_blacklists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_blacklists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_blacklists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_blacklists_id_seq OWNED BY public.email_blacklists.id;


--
-- Name: favorite_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorite_groups (
    id integer NOT NULL,
    name text NOT NULL,
    creator_id integer NOT NULL,
    post_ids text DEFAULT ''::text NOT NULL,
    post_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    is_public boolean DEFAULT false NOT NULL
);


--
-- Name: favorite_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.favorite_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favorite_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.favorite_groups_id_seq OWNED BY public.favorite_groups.id;


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL
);


--
-- Name: favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.favorites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.favorites_id_seq OWNED BY public.favorites.id;


--
-- Name: forum_post_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_post_votes (
    id bigint NOT NULL,
    forum_post_id integer NOT NULL,
    creator_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: forum_post_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_post_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_post_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_post_votes_id_seq OWNED BY public.forum_post_votes.id;


--
-- Name: forum_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_posts (
    id integer NOT NULL,
    topic_id integer NOT NULL,
    creator_id integer NOT NULL,
    updater_id integer NOT NULL,
    body text NOT NULL,
    text_index tsvector NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: forum_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_posts_id_seq OWNED BY public.forum_posts.id;


--
-- Name: forum_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_subscriptions (
    id integer NOT NULL,
    user_id integer,
    forum_topic_id integer,
    last_read_at timestamp without time zone,
    delete_key character varying
);


--
-- Name: forum_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_subscriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_subscriptions_id_seq OWNED BY public.forum_subscriptions.id;


--
-- Name: forum_topic_visits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_topic_visits (
    id integer NOT NULL,
    user_id integer,
    forum_topic_id integer,
    last_read_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: forum_topic_visits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_topic_visits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_topic_visits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_topic_visits_id_seq OWNED BY public.forum_topic_visits.id;


--
-- Name: forum_topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_topics (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    updater_id integer NOT NULL,
    title character varying NOT NULL,
    response_count integer DEFAULT 0 NOT NULL,
    is_sticky boolean DEFAULT false NOT NULL,
    is_locked boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    text_index tsvector NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    category_id integer DEFAULT 0 NOT NULL,
    min_level integer DEFAULT 0 NOT NULL
);


--
-- Name: forum_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_topics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_topics_id_seq OWNED BY public.forum_topics.id;


--
-- Name: ip_bans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ip_bans (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    ip_addr inet NOT NULL,
    reason text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: ip_bans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ip_bans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ip_bans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ip_bans_id_seq OWNED BY public.ip_bans.id;


--
-- Name: janitor_trials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.janitor_trials (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    user_id integer NOT NULL,
    original_level integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    status character varying DEFAULT 'active'::character varying NOT NULL
);


--
-- Name: janitor_trials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.janitor_trials_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: janitor_trials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.janitor_trials_id_seq OWNED BY public.janitor_trials.id;


--
-- Name: mod_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mod_actions (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    description text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    category integer
);


--
-- Name: mod_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mod_actions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mod_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mod_actions_id_seq OWNED BY public.mod_actions.id;


--
-- Name: news_updates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.news_updates (
    id integer NOT NULL,
    message text NOT NULL,
    creator_id integer NOT NULL,
    updater_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: news_updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.news_updates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: news_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.news_updates_id_seq OWNED BY public.news_updates.id;


--
-- Name: note_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.note_versions (
    id integer NOT NULL,
    note_id integer NOT NULL,
    post_id integer NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    x integer NOT NULL,
    y integer NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    body text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    version integer DEFAULT 0 NOT NULL
);


--
-- Name: note_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.note_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: note_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.note_versions_id_seq OWNED BY public.note_versions.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    post_id integer NOT NULL,
    x integer NOT NULL,
    y integer NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    body text NOT NULL,
    body_index tsvector NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    version integer DEFAULT 0 NOT NULL
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notes_id_seq
    AS integer
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
-- Name: pixiv_ugoira_frame_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pixiv_ugoira_frame_data (
    id integer NOT NULL,
    post_id integer,
    data text NOT NULL,
    content_type character varying NOT NULL
);


--
-- Name: pixiv_ugoira_frame_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pixiv_ugoira_frame_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pixiv_ugoira_frame_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pixiv_ugoira_frame_data_id_seq OWNED BY public.pixiv_ugoira_frame_data.id;


--
-- Name: pools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pools (
    id integer NOT NULL,
    name character varying,
    creator_id integer NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    post_ids integer[] DEFAULT '{}'::integer[] NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    category character varying DEFAULT 'series'::character varying NOT NULL
);


--
-- Name: pools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pools_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pools_id_seq OWNED BY public.pools.id;


--
-- Name: post_appeals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_appeals (
    id integer NOT NULL,
    post_id integer NOT NULL,
    creator_id integer NOT NULL,
    creator_ip_addr inet,
    reason text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: post_appeals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_appeals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_appeals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_appeals_id_seq OWNED BY public.post_appeals.id;


--
-- Name: post_approvals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_approvals (
    id integer NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: post_approvals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_approvals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_approvals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_approvals_id_seq OWNED BY public.post_approvals.id;


--
-- Name: post_disapprovals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_disapprovals (
    id integer NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    reason character varying DEFAULT 'legacy'::character varying,
    message text
);


--
-- Name: post_disapprovals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_disapprovals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_disapprovals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_disapprovals_id_seq OWNED BY public.post_disapprovals.id;


--
-- Name: post_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_flags (
    id integer NOT NULL,
    post_id integer NOT NULL,
    creator_id integer NOT NULL,
    creator_ip_addr inet NOT NULL,
    reason text,
    is_resolved boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: post_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_flags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_flags_id_seq OWNED BY public.post_flags.id;


--
-- Name: post_replacements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_replacements (
    id integer NOT NULL,
    post_id integer NOT NULL,
    creator_id integer NOT NULL,
    original_url text NOT NULL,
    replacement_url text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    file_ext_was character varying,
    file_size_was integer,
    image_width_was integer,
    image_height_was integer,
    md5_was character varying,
    file_ext character varying,
    file_size integer,
    image_width integer,
    image_height integer,
    md5 character varying
);


--
-- Name: post_replacements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_replacements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_replacements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_replacements_id_seq OWNED BY public.post_replacements.id;


--
-- Name: post_updates; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.post_updates (
    post_id integer
);


--
-- Name: post_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_votes (
    id integer NOT NULL,
    post_id integer NOT NULL,
    user_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: post_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_votes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_votes_id_seq OWNED BY public.post_votes.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    up_score integer DEFAULT 0 NOT NULL,
    down_score integer DEFAULT 0 NOT NULL,
    score integer DEFAULT 0 NOT NULL,
    source character varying DEFAULT ''::character varying NOT NULL,
    md5 character varying NOT NULL,
    rating character(1) DEFAULT 'q'::bpchar NOT NULL,
    is_note_locked boolean DEFAULT false NOT NULL,
    is_rating_locked boolean DEFAULT false NOT NULL,
    is_status_locked boolean DEFAULT false NOT NULL,
    is_pending boolean DEFAULT false NOT NULL,
    is_flagged boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    uploader_id integer NOT NULL,
    uploader_ip_addr inet NOT NULL,
    approver_id integer,
    fav_string text DEFAULT ''::text NOT NULL,
    pool_string text DEFAULT ''::text NOT NULL,
    last_noted_at timestamp without time zone,
    last_comment_bumped_at timestamp without time zone,
    fav_count integer DEFAULT 0 NOT NULL,
    tag_string text DEFAULT ''::text NOT NULL,
    tag_index tsvector,
    tag_count integer DEFAULT 0 NOT NULL,
    tag_count_general integer DEFAULT 0 NOT NULL,
    tag_count_artist integer DEFAULT 0 NOT NULL,
    tag_count_character integer DEFAULT 0 NOT NULL,
    tag_count_copyright integer DEFAULT 0 NOT NULL,
    file_ext character varying NOT NULL,
    file_size integer NOT NULL,
    image_width integer NOT NULL,
    image_height integer NOT NULL,
    parent_id integer,
    has_children boolean DEFAULT false NOT NULL,
    pixiv_id integer,
    last_commented_at timestamp without time zone,
    has_active_children boolean DEFAULT false,
    bit_flags bigint DEFAULT 0 NOT NULL,
    tag_count_meta integer DEFAULT 0 NOT NULL,
    locked_tags text
);


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: saved_searches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.saved_searches (
    id integer NOT NULL,
    user_id integer,
    query text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    labels text[] DEFAULT '{}'::text[] NOT NULL
);


--
-- Name: saved_searches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.saved_searches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: saved_searches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.saved_searches_id_seq OWNED BY public.saved_searches.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: super_voters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.super_voters (
    id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: super_voters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.super_voters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: super_voters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.super_voters_id_seq OWNED BY public.super_voters.id;


--
-- Name: tag_aliases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_aliases (
    id integer NOT NULL,
    antecedent_name character varying NOT NULL,
    consequent_name character varying NOT NULL,
    creator_id integer NOT NULL,
    creator_ip_addr inet NOT NULL,
    forum_topic_id integer,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    post_count integer DEFAULT 0 NOT NULL,
    approver_id integer,
    forum_post_id integer
);


--
-- Name: tag_aliases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_aliases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_aliases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_aliases_id_seq OWNED BY public.tag_aliases.id;


--
-- Name: tag_implications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_implications (
    id integer NOT NULL,
    antecedent_name character varying NOT NULL,
    consequent_name character varying NOT NULL,
    creator_id integer NOT NULL,
    creator_ip_addr inet NOT NULL,
    forum_topic_id integer,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    approver_id integer,
    forum_post_id integer,
    descendant_names text[] DEFAULT '{}'::text[]
);


--
-- Name: tag_implications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_implications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_implications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_implications_id_seq OWNED BY public.tag_implications.id;


--
-- Name: tag_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_subscriptions (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    name character varying NOT NULL,
    tag_query text NOT NULL,
    post_ids text NOT NULL,
    is_public boolean DEFAULT true NOT NULL,
    last_accessed_at timestamp without time zone,
    is_opted_in boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: tag_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_subscriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_subscriptions_id_seq OWNED BY public.tag_subscriptions.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id integer NOT NULL,
    name character varying NOT NULL,
    post_count integer DEFAULT 0 NOT NULL,
    category integer DEFAULT 0 NOT NULL,
    related_tags text,
    related_tags_updated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_locked boolean DEFAULT false NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    AS integer
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
-- Name: token_buckets; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.token_buckets (
    user_id integer,
    last_touched_at timestamp without time zone NOT NULL,
    token_count real NOT NULL
);


--
-- Name: upload_whitelists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upload_whitelists (
    id bigint NOT NULL,
    pattern character varying NOT NULL,
    note character varying,
    reason character varying,
    allowed boolean DEFAULT true NOT NULL,
    hidden boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: upload_whitelists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upload_whitelists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upload_whitelists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upload_whitelists_id_seq OWNED BY public.upload_whitelists.id;


--
-- Name: uploads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.uploads (
    id integer NOT NULL,
    source text,
    file_path character varying,
    content_type character varying,
    rating character(1) NOT NULL,
    uploader_id integer NOT NULL,
    uploader_ip_addr inet NOT NULL,
    tag_string text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    backtrace text,
    post_id integer,
    md5_confirmation character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    server text,
    parent_id integer,
    md5 character varying,
    file_ext character varying,
    file_size integer,
    image_width integer,
    image_height integer,
    artist_commentary_desc text,
    artist_commentary_title text,
    include_artist_commentary boolean,
    context text,
    referer_url text
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.uploads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.uploads_id_seq OWNED BY public.uploads.id;


--
-- Name: user_feedback; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_feedback (
    id integer NOT NULL,
    user_id integer NOT NULL,
    creator_id integer NOT NULL,
    category character varying NOT NULL,
    body text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_ip_addr inet
);


--
-- Name: user_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_feedback_id_seq OWNED BY public.user_feedback.id;


--
-- Name: user_name_change_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_name_change_requests (
    id integer NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    user_id integer NOT NULL,
    approver_id integer,
    original_name character varying,
    desired_name character varying,
    change_reason text,
    rejection_reason text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_name_change_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_name_change_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_name_change_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_name_change_requests_id_seq OWNED BY public.user_name_change_requests.id;


--
-- Name: user_password_reset_nonces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_password_reset_nonces (
    id integer NOT NULL,
    key character varying NOT NULL,
    email character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_password_reset_nonces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_password_reset_nonces_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_password_reset_nonces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_password_reset_nonces_id_seq OWNED BY public.user_password_reset_nonces.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name character varying NOT NULL,
    password_hash character varying NOT NULL,
    email character varying,
    email_verification_key character varying,
    inviter_id integer,
    level integer DEFAULT 0 NOT NULL,
    base_upload_limit integer DEFAULT 10 NOT NULL,
    last_logged_in_at timestamp without time zone,
    last_forum_read_at timestamp without time zone,
    recent_tags text,
    post_upload_count integer DEFAULT 0 NOT NULL,
    post_update_count integer DEFAULT 0 NOT NULL,
    note_update_count integer DEFAULT 0 NOT NULL,
    favorite_count integer DEFAULT 0 NOT NULL,
    comment_threshold integer DEFAULT '-1'::integer NOT NULL,
    default_image_size character varying DEFAULT 'large'::character varying NOT NULL,
    favorite_tags text,
    blacklisted_tags text DEFAULT 'spoilers
guro
scat
furry -rating:s'::text,
    time_zone character varying DEFAULT 'Eastern Time (US & Canada)'::character varying NOT NULL,
    bcrypt_password_hash text,
    per_page integer DEFAULT 20 NOT NULL,
    custom_style text,
    bit_prefs bigint DEFAULT 0 NOT NULL,
    last_ip_addr inet,
    unread_dmail_count integer DEFAULT 0 NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
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
-- Name: wiki_page_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wiki_page_versions (
    id integer NOT NULL,
    wiki_page_id integer NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    title character varying NOT NULL,
    body text NOT NULL,
    is_locked boolean NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    other_names text[] DEFAULT '{}'::text[] NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: wiki_page_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wiki_page_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wiki_page_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wiki_page_versions_id_seq OWNED BY public.wiki_page_versions.id;


--
-- Name: wiki_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wiki_pages (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    title character varying NOT NULL,
    body text NOT NULL,
    body_index tsvector NOT NULL,
    is_locked boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    updater_id integer,
    other_names text[] DEFAULT '{}'::text[] NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: wiki_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wiki_pages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wiki_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wiki_pages_id_seq OWNED BY public.wiki_pages.id;


--
-- Name: advertisement_hits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advertisement_hits ALTER COLUMN id SET DEFAULT nextval('public.advertisement_hits_id_seq'::regclass);


--
-- Name: advertisements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advertisements ALTER COLUMN id SET DEFAULT nextval('public.advertisements_id_seq'::regclass);


--
-- Name: amazon_backups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.amazon_backups ALTER COLUMN id SET DEFAULT nextval('public.amazon_backups_id_seq'::regclass);


--
-- Name: anti_voters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anti_voters ALTER COLUMN id SET DEFAULT nextval('public.anti_voters_id_seq'::regclass);


--
-- Name: api_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys ALTER COLUMN id SET DEFAULT nextval('public.api_keys_id_seq'::regclass);


--
-- Name: artist_commentaries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_commentaries ALTER COLUMN id SET DEFAULT nextval('public.artist_commentaries_id_seq'::regclass);


--
-- Name: artist_commentary_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_commentary_versions ALTER COLUMN id SET DEFAULT nextval('public.artist_commentary_versions_id_seq'::regclass);


--
-- Name: artist_urls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_urls ALTER COLUMN id SET DEFAULT nextval('public.artist_urls_id_seq'::regclass);


--
-- Name: artist_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_versions ALTER COLUMN id SET DEFAULT nextval('public.artist_versions_id_seq'::regclass);


--
-- Name: artists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artists ALTER COLUMN id SET DEFAULT nextval('public.artists_id_seq'::regclass);


--
-- Name: bans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bans ALTER COLUMN id SET DEFAULT nextval('public.bans_id_seq'::regclass);


--
-- Name: bulk_update_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_update_requests ALTER COLUMN id SET DEFAULT nextval('public.bulk_update_requests_id_seq'::regclass);


--
-- Name: comment_votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_votes ALTER COLUMN id SET DEFAULT nextval('public.comment_votes_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);


--
-- Name: dmail_filters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dmail_filters ALTER COLUMN id SET DEFAULT nextval('public.dmail_filters_id_seq'::regclass);


--
-- Name: dmails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dmails ALTER COLUMN id SET DEFAULT nextval('public.dmails_id_seq'::regclass);


--
-- Name: email_blacklists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_blacklists ALTER COLUMN id SET DEFAULT nextval('public.email_blacklists_id_seq'::regclass);


--
-- Name: favorite_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_groups ALTER COLUMN id SET DEFAULT nextval('public.favorite_groups_id_seq'::regclass);


--
-- Name: favorites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: forum_post_votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_post_votes ALTER COLUMN id SET DEFAULT nextval('public.forum_post_votes_id_seq'::regclass);


--
-- Name: forum_posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_posts ALTER COLUMN id SET DEFAULT nextval('public.forum_posts_id_seq'::regclass);


--
-- Name: forum_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.forum_subscriptions_id_seq'::regclass);


--
-- Name: forum_topic_visits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topic_visits ALTER COLUMN id SET DEFAULT nextval('public.forum_topic_visits_id_seq'::regclass);


--
-- Name: forum_topics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topics ALTER COLUMN id SET DEFAULT nextval('public.forum_topics_id_seq'::regclass);


--
-- Name: ip_bans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ip_bans ALTER COLUMN id SET DEFAULT nextval('public.ip_bans_id_seq'::regclass);


--
-- Name: janitor_trials id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.janitor_trials ALTER COLUMN id SET DEFAULT nextval('public.janitor_trials_id_seq'::regclass);


--
-- Name: mod_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_actions ALTER COLUMN id SET DEFAULT nextval('public.mod_actions_id_seq'::regclass);


--
-- Name: news_updates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_updates ALTER COLUMN id SET DEFAULT nextval('public.news_updates_id_seq'::regclass);


--
-- Name: note_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_versions ALTER COLUMN id SET DEFAULT nextval('public.note_versions_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Name: pixiv_ugoira_frame_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pixiv_ugoira_frame_data ALTER COLUMN id SET DEFAULT nextval('public.pixiv_ugoira_frame_data_id_seq'::regclass);


--
-- Name: pools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pools ALTER COLUMN id SET DEFAULT nextval('public.pools_id_seq'::regclass);


--
-- Name: post_appeals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_appeals ALTER COLUMN id SET DEFAULT nextval('public.post_appeals_id_seq'::regclass);


--
-- Name: post_approvals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_approvals ALTER COLUMN id SET DEFAULT nextval('public.post_approvals_id_seq'::regclass);


--
-- Name: post_disapprovals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_disapprovals ALTER COLUMN id SET DEFAULT nextval('public.post_disapprovals_id_seq'::regclass);


--
-- Name: post_flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_flags ALTER COLUMN id SET DEFAULT nextval('public.post_flags_id_seq'::regclass);


--
-- Name: post_replacements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_replacements ALTER COLUMN id SET DEFAULT nextval('public.post_replacements_id_seq'::regclass);


--
-- Name: post_votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_votes ALTER COLUMN id SET DEFAULT nextval('public.post_votes_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);


--
-- Name: saved_searches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_searches ALTER COLUMN id SET DEFAULT nextval('public.saved_searches_id_seq'::regclass);


--
-- Name: super_voters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.super_voters ALTER COLUMN id SET DEFAULT nextval('public.super_voters_id_seq'::regclass);


--
-- Name: tag_aliases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_aliases ALTER COLUMN id SET DEFAULT nextval('public.tag_aliases_id_seq'::regclass);


--
-- Name: tag_implications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_implications ALTER COLUMN id SET DEFAULT nextval('public.tag_implications_id_seq'::regclass);


--
-- Name: tag_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.tag_subscriptions_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: upload_whitelists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upload_whitelists ALTER COLUMN id SET DEFAULT nextval('public.upload_whitelists_id_seq'::regclass);


--
-- Name: uploads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploads ALTER COLUMN id SET DEFAULT nextval('public.uploads_id_seq'::regclass);


--
-- Name: user_feedback id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_feedback ALTER COLUMN id SET DEFAULT nextval('public.user_feedback_id_seq'::regclass);


--
-- Name: user_name_change_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_name_change_requests ALTER COLUMN id SET DEFAULT nextval('public.user_name_change_requests_id_seq'::regclass);


--
-- Name: user_password_reset_nonces id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_password_reset_nonces ALTER COLUMN id SET DEFAULT nextval('public.user_password_reset_nonces_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: wiki_page_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_page_versions ALTER COLUMN id SET DEFAULT nextval('public.wiki_page_versions_id_seq'::regclass);


--
-- Name: wiki_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_pages ALTER COLUMN id SET DEFAULT nextval('public.wiki_pages_id_seq'::regclass);


--
-- Name: advertisement_hits advertisement_hits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advertisement_hits
    ADD CONSTRAINT advertisement_hits_pkey PRIMARY KEY (id);


--
-- Name: advertisements advertisements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advertisements
    ADD CONSTRAINT advertisements_pkey PRIMARY KEY (id);


--
-- Name: amazon_backups amazon_backups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.amazon_backups
    ADD CONSTRAINT amazon_backups_pkey PRIMARY KEY (id);


--
-- Name: anti_voters anti_voters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anti_voters
    ADD CONSTRAINT anti_voters_pkey PRIMARY KEY (id);


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
-- Name: artist_commentaries artist_commentaries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_commentaries
    ADD CONSTRAINT artist_commentaries_pkey PRIMARY KEY (id);


--
-- Name: artist_commentary_versions artist_commentary_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_commentary_versions
    ADD CONSTRAINT artist_commentary_versions_pkey PRIMARY KEY (id);


--
-- Name: artist_urls artist_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_urls
    ADD CONSTRAINT artist_urls_pkey PRIMARY KEY (id);


--
-- Name: artist_versions artist_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_versions
    ADD CONSTRAINT artist_versions_pkey PRIMARY KEY (id);


--
-- Name: artists artists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artists
    ADD CONSTRAINT artists_pkey PRIMARY KEY (id);


--
-- Name: bans bans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bans
    ADD CONSTRAINT bans_pkey PRIMARY KEY (id);


--
-- Name: bulk_update_requests bulk_update_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_update_requests
    ADD CONSTRAINT bulk_update_requests_pkey PRIMARY KEY (id);


--
-- Name: comment_votes comment_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_votes
    ADD CONSTRAINT comment_votes_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: dmail_filters dmail_filters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dmail_filters
    ADD CONSTRAINT dmail_filters_pkey PRIMARY KEY (id);


--
-- Name: dmails dmails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dmails
    ADD CONSTRAINT dmails_pkey PRIMARY KEY (id);


--
-- Name: email_blacklists email_blacklists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_blacklists
    ADD CONSTRAINT email_blacklists_pkey PRIMARY KEY (id);


--
-- Name: favorite_groups favorite_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_groups
    ADD CONSTRAINT favorite_groups_pkey PRIMARY KEY (id);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


--
-- Name: forum_post_votes forum_post_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_post_votes
    ADD CONSTRAINT forum_post_votes_pkey PRIMARY KEY (id);


--
-- Name: forum_posts forum_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_posts
    ADD CONSTRAINT forum_posts_pkey PRIMARY KEY (id);


--
-- Name: forum_subscriptions forum_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_subscriptions
    ADD CONSTRAINT forum_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: forum_topic_visits forum_topic_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topic_visits
    ADD CONSTRAINT forum_topic_visits_pkey PRIMARY KEY (id);


--
-- Name: forum_topics forum_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topics
    ADD CONSTRAINT forum_topics_pkey PRIMARY KEY (id);


--
-- Name: ip_bans ip_bans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ip_bans
    ADD CONSTRAINT ip_bans_pkey PRIMARY KEY (id);


--
-- Name: janitor_trials janitor_trials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.janitor_trials
    ADD CONSTRAINT janitor_trials_pkey PRIMARY KEY (id);


--
-- Name: mod_actions mod_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_actions
    ADD CONSTRAINT mod_actions_pkey PRIMARY KEY (id);


--
-- Name: news_updates news_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_updates
    ADD CONSTRAINT news_updates_pkey PRIMARY KEY (id);


--
-- Name: note_versions note_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_versions
    ADD CONSTRAINT note_versions_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: pixiv_ugoira_frame_data pixiv_ugoira_frame_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pixiv_ugoira_frame_data
    ADD CONSTRAINT pixiv_ugoira_frame_data_pkey PRIMARY KEY (id);


--
-- Name: pools pools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pools
    ADD CONSTRAINT pools_pkey PRIMARY KEY (id);


--
-- Name: post_appeals post_appeals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_appeals
    ADD CONSTRAINT post_appeals_pkey PRIMARY KEY (id);


--
-- Name: post_approvals post_approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_approvals
    ADD CONSTRAINT post_approvals_pkey PRIMARY KEY (id);


--
-- Name: post_disapprovals post_disapprovals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_disapprovals
    ADD CONSTRAINT post_disapprovals_pkey PRIMARY KEY (id);


--
-- Name: post_flags post_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_flags
    ADD CONSTRAINT post_flags_pkey PRIMARY KEY (id);


--
-- Name: post_replacements post_replacements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_replacements
    ADD CONSTRAINT post_replacements_pkey PRIMARY KEY (id);


--
-- Name: post_votes post_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_votes
    ADD CONSTRAINT post_votes_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: saved_searches saved_searches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_searches
    ADD CONSTRAINT saved_searches_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: super_voters super_voters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.super_voters
    ADD CONSTRAINT super_voters_pkey PRIMARY KEY (id);


--
-- Name: tag_aliases tag_aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_aliases
    ADD CONSTRAINT tag_aliases_pkey PRIMARY KEY (id);


--
-- Name: tag_implications tag_implications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_implications
    ADD CONSTRAINT tag_implications_pkey PRIMARY KEY (id);


--
-- Name: tag_subscriptions tag_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_subscriptions
    ADD CONSTRAINT tag_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: upload_whitelists upload_whitelists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upload_whitelists
    ADD CONSTRAINT upload_whitelists_pkey PRIMARY KEY (id);


--
-- Name: uploads uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: user_feedback user_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_feedback
    ADD CONSTRAINT user_feedback_pkey PRIMARY KEY (id);


--
-- Name: user_name_change_requests user_name_change_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_name_change_requests
    ADD CONSTRAINT user_name_change_requests_pkey PRIMARY KEY (id);


--
-- Name: user_password_reset_nonces user_password_reset_nonces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_password_reset_nonces
    ADD CONSTRAINT user_password_reset_nonces_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: wiki_page_versions wiki_page_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_page_versions
    ADD CONSTRAINT wiki_page_versions_pkey PRIMARY KEY (id);


--
-- Name: wiki_pages wiki_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_pages
    ADD CONSTRAINT wiki_pages_pkey PRIMARY KEY (id);


--
-- Name: index_advertisement_hits_on_advertisement_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advertisement_hits_on_advertisement_id ON public.advertisement_hits USING btree (advertisement_id);


--
-- Name: index_advertisement_hits_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advertisement_hits_on_created_at ON public.advertisement_hits USING btree (created_at);


--
-- Name: index_advertisements_on_ad_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advertisements_on_ad_type ON public.advertisements USING btree (ad_type);


--
-- Name: index_api_keys_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_api_keys_on_key ON public.api_keys USING btree (key);


--
-- Name: index_api_keys_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_api_keys_on_user_id ON public.api_keys USING btree (user_id);


--
-- Name: index_artist_commentaries_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_artist_commentaries_on_post_id ON public.artist_commentaries USING btree (post_id);


--
-- Name: index_artist_commentary_versions_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_commentary_versions_on_post_id ON public.artist_commentary_versions USING btree (post_id);


--
-- Name: index_artist_commentary_versions_on_updater_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_commentary_versions_on_updater_id_and_post_id ON public.artist_commentary_versions USING btree (updater_id, post_id);


--
-- Name: index_artist_commentary_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_commentary_versions_on_updater_ip_addr ON public.artist_commentary_versions USING btree (updater_ip_addr);


--
-- Name: index_artist_urls_on_artist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_artist_id ON public.artist_urls USING btree (artist_id);


--
-- Name: index_artist_urls_on_normalized_url_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_normalized_url_pattern ON public.artist_urls USING btree (normalized_url text_pattern_ops);


--
-- Name: index_artist_urls_on_normalized_url_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_normalized_url_trgm ON public.artist_urls USING gin (normalized_url public.gin_trgm_ops);


--
-- Name: index_artist_urls_on_url_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_url_trgm ON public.artist_urls USING gin (url public.gin_trgm_ops);


--
-- Name: index_artist_versions_on_artist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_artist_id ON public.artist_versions USING btree (artist_id);


--
-- Name: index_artist_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_created_at ON public.artist_versions USING btree (created_at);


--
-- Name: index_artist_versions_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_name ON public.artist_versions USING btree (name);


--
-- Name: index_artist_versions_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_updater_id ON public.artist_versions USING btree (updater_id);


--
-- Name: index_artist_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_updater_ip_addr ON public.artist_versions USING btree (updater_ip_addr);


--
-- Name: index_artists_on_group_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_group_name ON public.artists USING btree (group_name);


--
-- Name: index_artists_on_group_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_group_name_trgm ON public.artists USING gin (group_name public.gin_trgm_ops);


--
-- Name: index_artists_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_artists_on_name ON public.artists USING btree (name);


--
-- Name: index_artists_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_name_trgm ON public.artists USING gin (name public.gin_trgm_ops);


--
-- Name: index_artists_on_other_names; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_other_names ON public.artists USING gin (other_names);


--
-- Name: index_bans_on_banner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bans_on_banner_id ON public.bans USING btree (banner_id);


--
-- Name: index_bans_on_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bans_on_expires_at ON public.bans USING btree (expires_at);


--
-- Name: index_bans_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bans_on_user_id ON public.bans USING btree (user_id);


--
-- Name: index_bulk_update_requests_on_forum_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bulk_update_requests_on_forum_post_id ON public.bulk_update_requests USING btree (forum_post_id);


--
-- Name: index_comment_votes_on_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_votes_on_comment_id ON public.comment_votes USING btree (comment_id);


--
-- Name: index_comment_votes_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_votes_on_created_at ON public.comment_votes USING btree (created_at);


--
-- Name: index_comment_votes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_votes_on_user_id ON public.comment_votes USING btree (user_id);


--
-- Name: index_comments_on_body_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_body_index ON public.comments USING gin (body_index);


--
-- Name: index_comments_on_creator_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_creator_id_and_post_id ON public.comments USING btree (creator_id, post_id);


--
-- Name: index_comments_on_creator_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_creator_ip_addr ON public.comments USING btree (creator_ip_addr);


--
-- Name: index_comments_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_post_id ON public.comments USING btree (post_id);


--
-- Name: index_delayed_jobs_on_run_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delayed_jobs_on_run_at ON public.delayed_jobs USING btree (run_at);


--
-- Name: index_dmail_filters_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_dmail_filters_on_user_id ON public.dmail_filters USING btree (user_id);


--
-- Name: index_dmails_on_creator_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_creator_ip_addr ON public.dmails USING btree (creator_ip_addr);


--
-- Name: index_dmails_on_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_is_deleted ON public.dmails USING btree (is_deleted);


--
-- Name: index_dmails_on_is_read; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_is_read ON public.dmails USING btree (is_read);


--
-- Name: index_dmails_on_message_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_message_index ON public.dmails USING gin (message_index);


--
-- Name: index_dmails_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_owner_id ON public.dmails USING btree (owner_id);


--
-- Name: index_favorite_groups_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorite_groups_on_creator_id ON public.favorite_groups USING btree (creator_id);


--
-- Name: index_favorite_groups_on_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorite_groups_on_lower_name ON public.favorite_groups USING btree (lower(name));


--
-- Name: index_favorites_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_on_post_id ON public.favorites USING btree (post_id);


--
-- Name: index_favorites_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_on_user_id ON public.favorites USING btree (user_id);


--
-- Name: index_forum_post_votes_on_forum_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_post_votes_on_forum_post_id ON public.forum_post_votes USING btree (forum_post_id);


--
-- Name: index_forum_post_votes_on_forum_post_id_and_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_forum_post_votes_on_forum_post_id_and_creator_id ON public.forum_post_votes USING btree (forum_post_id, creator_id);


--
-- Name: index_forum_posts_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_posts_on_creator_id ON public.forum_posts USING btree (creator_id);


--
-- Name: index_forum_posts_on_text_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_posts_on_text_index ON public.forum_posts USING gin (text_index);


--
-- Name: index_forum_posts_on_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_posts_on_topic_id ON public.forum_posts USING btree (topic_id);


--
-- Name: index_forum_subscriptions_on_forum_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_subscriptions_on_forum_topic_id ON public.forum_subscriptions USING btree (forum_topic_id);


--
-- Name: index_forum_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_subscriptions_on_user_id ON public.forum_subscriptions USING btree (user_id);


--
-- Name: index_forum_topic_visits_on_forum_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topic_visits_on_forum_topic_id ON public.forum_topic_visits USING btree (forum_topic_id);


--
-- Name: index_forum_topic_visits_on_last_read_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topic_visits_on_last_read_at ON public.forum_topic_visits USING btree (last_read_at);


--
-- Name: index_forum_topic_visits_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topic_visits_on_user_id ON public.forum_topic_visits USING btree (user_id);


--
-- Name: index_forum_topics_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_creator_id ON public.forum_topics USING btree (creator_id);


--
-- Name: index_forum_topics_on_is_sticky_and_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_is_sticky_and_updated_at ON public.forum_topics USING btree (is_sticky, updated_at);


--
-- Name: index_forum_topics_on_text_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_text_index ON public.forum_topics USING gin (text_index);


--
-- Name: index_forum_topics_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_updated_at ON public.forum_topics USING btree (updated_at);


--
-- Name: index_ip_bans_on_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ip_bans_on_ip_addr ON public.ip_bans USING btree (ip_addr);


--
-- Name: index_janitor_trials_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_janitor_trials_on_user_id ON public.janitor_trials USING btree (user_id);


--
-- Name: index_news_updates_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_updates_on_created_at ON public.news_updates USING btree (created_at);


--
-- Name: index_note_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_created_at ON public.note_versions USING btree (created_at);


--
-- Name: index_note_versions_on_note_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_note_id ON public.note_versions USING btree (note_id);


--
-- Name: index_note_versions_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_post_id ON public.note_versions USING btree (post_id);


--
-- Name: index_note_versions_on_updater_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_updater_id_and_post_id ON public.note_versions USING btree (updater_id, post_id);


--
-- Name: index_note_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_updater_ip_addr ON public.note_versions USING btree (updater_ip_addr);


--
-- Name: index_notes_on_body_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_body_index ON public.notes USING gin (body_index);


--
-- Name: index_notes_on_creator_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_creator_id_and_post_id ON public.notes USING btree (creator_id, post_id);


--
-- Name: index_notes_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_post_id ON public.notes USING btree (post_id);


--
-- Name: index_pixiv_ugoira_frame_data_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pixiv_ugoira_frame_data_on_post_id ON public.pixiv_ugoira_frame_data USING btree (post_id);


--
-- Name: index_pools_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_creator_id ON public.pools USING btree (creator_id);


--
-- Name: index_pools_on_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_lower_name ON public.pools USING btree (lower((name)::text));


--
-- Name: index_pools_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_name ON public.pools USING btree (name);


--
-- Name: index_pools_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_name_trgm ON public.pools USING gin (lower((name)::text) public.gin_trgm_ops);


--
-- Name: index_pools_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_updated_at ON public.pools USING btree (updated_at);


--
-- Name: index_post_appeals_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_created_at ON public.post_appeals USING btree (created_at);


--
-- Name: index_post_appeals_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_creator_id ON public.post_appeals USING btree (creator_id);


--
-- Name: index_post_appeals_on_creator_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_creator_ip_addr ON public.post_appeals USING btree (creator_ip_addr);


--
-- Name: index_post_appeals_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_post_id ON public.post_appeals USING btree (post_id);


--
-- Name: index_post_appeals_on_reason_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_reason_tsvector ON public.post_appeals USING gin (to_tsvector('english'::regconfig, reason));


--
-- Name: index_post_approvals_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_approvals_on_post_id ON public.post_approvals USING btree (post_id);


--
-- Name: index_post_approvals_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_approvals_on_user_id ON public.post_approvals USING btree (user_id);


--
-- Name: index_post_disapprovals_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_disapprovals_on_post_id ON public.post_disapprovals USING btree (post_id);


--
-- Name: index_post_disapprovals_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_disapprovals_on_user_id ON public.post_disapprovals USING btree (user_id);


--
-- Name: index_post_flags_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_creator_id ON public.post_flags USING btree (creator_id);


--
-- Name: index_post_flags_on_creator_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_creator_ip_addr ON public.post_flags USING btree (creator_ip_addr);


--
-- Name: index_post_flags_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_post_id ON public.post_flags USING btree (post_id);


--
-- Name: index_post_flags_on_reason_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_reason_tsvector ON public.post_flags USING gin (to_tsvector('english'::regconfig, reason));


--
-- Name: index_post_replacements_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_replacements_on_creator_id ON public.post_replacements USING btree (creator_id);


--
-- Name: index_post_replacements_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_replacements_on_post_id ON public.post_replacements USING btree (post_id);


--
-- Name: index_post_votes_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_votes_on_post_id ON public.post_votes USING btree (post_id);


--
-- Name: index_post_votes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_votes_on_user_id ON public.post_votes USING btree (user_id);


--
-- Name: index_posts_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_created_at ON public.posts USING btree (created_at);


--
-- Name: index_posts_on_file_size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_file_size ON public.posts USING btree (file_size);


--
-- Name: index_posts_on_image_height; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_image_height ON public.posts USING btree (image_height);


--
-- Name: index_posts_on_image_width; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_image_width ON public.posts USING btree (image_width);


--
-- Name: index_posts_on_is_flagged; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_is_flagged ON public.posts USING btree (is_flagged) WHERE (is_flagged = true);


--
-- Name: index_posts_on_is_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_is_pending ON public.posts USING btree (is_pending) WHERE (is_pending = true);


--
-- Name: index_posts_on_last_comment_bumped_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_last_comment_bumped_at ON public.posts USING btree (last_comment_bumped_at DESC NULLS LAST);


--
-- Name: index_posts_on_last_noted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_last_noted_at ON public.posts USING btree (last_noted_at DESC NULLS LAST);


--
-- Name: index_posts_on_md5; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_posts_on_md5 ON public.posts USING btree (md5);


--
-- Name: index_posts_on_mpixels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_mpixels ON public.posts USING btree (((((image_width * image_height))::numeric / 1000000.0)));


--
-- Name: index_posts_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_parent_id ON public.posts USING btree (parent_id);


--
-- Name: index_posts_on_pixiv_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_pixiv_id ON public.posts USING btree (pixiv_id) WHERE (pixiv_id IS NOT NULL);


--
-- Name: index_posts_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_source ON public.posts USING btree (lower((source)::text));


--
-- Name: index_posts_on_source_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_source_pattern ON public.posts USING btree (public.sourcepattern(lower((source)::text)) text_pattern_ops);


--
-- Name: index_posts_on_tags_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_tags_index ON public.posts USING gin (tag_index);


--
-- Name: index_posts_on_uploader_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_uploader_id ON public.posts USING btree (uploader_id);


--
-- Name: index_posts_on_uploader_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_uploader_ip_addr ON public.posts USING btree (uploader_ip_addr);


--
-- Name: index_saved_searches_on_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_saved_searches_on_labels ON public.saved_searches USING gin (labels);


--
-- Name: index_saved_searches_on_query; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_saved_searches_on_query ON public.saved_searches USING btree (query);


--
-- Name: index_saved_searches_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_saved_searches_on_user_id ON public.saved_searches USING btree (user_id);


--
-- Name: index_tag_aliases_on_antecedent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_antecedent_name ON public.tag_aliases USING btree (antecedent_name);


--
-- Name: index_tag_aliases_on_antecedent_name_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_antecedent_name_pattern ON public.tag_aliases USING btree (antecedent_name text_pattern_ops);


--
-- Name: index_tag_aliases_on_consequent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_consequent_name ON public.tag_aliases USING btree (consequent_name);


--
-- Name: index_tag_aliases_on_forum_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_forum_post_id ON public.tag_aliases USING btree (forum_post_id);


--
-- Name: index_tag_aliases_on_post_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_post_count ON public.tag_aliases USING btree (post_count);


--
-- Name: index_tag_implications_on_antecedent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_implications_on_antecedent_name ON public.tag_implications USING btree (antecedent_name);


--
-- Name: index_tag_implications_on_consequent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_implications_on_consequent_name ON public.tag_implications USING btree (consequent_name);


--
-- Name: index_tag_implications_on_forum_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_implications_on_forum_post_id ON public.tag_implications USING btree (forum_post_id);


--
-- Name: index_tag_subscriptions_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_subscriptions_on_creator_id ON public.tag_subscriptions USING btree (creator_id);


--
-- Name: index_tag_subscriptions_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_subscriptions_on_name ON public.tag_subscriptions USING btree (name);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_on_name ON public.tags USING btree (name);


--
-- Name: index_tags_on_name_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_name_pattern ON public.tags USING btree (name text_pattern_ops);


--
-- Name: index_tags_on_name_prefix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_name_prefix ON public.tags USING gin (regexp_replace((name)::text, '([a-z0-9])[a-z0-9'']*($|[^a-z0-9'']+)'::text, '\1'::text, 'g'::text) public.gin_trgm_ops);


--
-- Name: index_tags_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_name_trgm ON public.tags USING gin (name public.gin_trgm_ops);


--
-- Name: index_token_buckets_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_token_buckets_on_user_id ON public.token_buckets USING btree (user_id);


--
-- Name: index_uploads_on_referer_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_referer_url ON public.uploads USING btree (referer_url);


--
-- Name: index_uploads_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_source ON public.uploads USING btree (source);


--
-- Name: index_uploads_on_uploader_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_uploader_id ON public.uploads USING btree (uploader_id);


--
-- Name: index_uploads_on_uploader_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_uploader_ip_addr ON public.uploads USING btree (uploader_ip_addr);


--
-- Name: index_user_feedback_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_feedback_on_created_at ON public.user_feedback USING btree (created_at);


--
-- Name: index_user_feedback_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_feedback_on_creator_id ON public.user_feedback USING btree (creator_id);


--
-- Name: index_user_feedback_on_creator_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_feedback_on_creator_ip_addr ON public.user_feedback USING btree (creator_ip_addr);


--
-- Name: index_user_feedback_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_feedback_on_user_id ON public.user_feedback USING btree (user_id);


--
-- Name: index_user_name_change_requests_on_original_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_name_change_requests_on_original_name ON public.user_name_change_requests USING btree (original_name);


--
-- Name: index_user_name_change_requests_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_name_change_requests_on_user_id ON public.user_name_change_requests USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_last_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_last_ip_addr ON public.users USING btree (last_ip_addr) WHERE (last_ip_addr IS NOT NULL);


--
-- Name: index_users_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_name ON public.users USING btree (lower((name)::text));


--
-- Name: index_users_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_name_trgm ON public.users USING gin (lower((name)::text) public.gin_trgm_ops);


--
-- Name: index_wiki_page_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_page_versions_on_created_at ON public.wiki_page_versions USING btree (created_at);


--
-- Name: index_wiki_page_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_page_versions_on_updater_ip_addr ON public.wiki_page_versions USING btree (updater_ip_addr);


--
-- Name: index_wiki_page_versions_on_wiki_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_page_versions_on_wiki_page_id ON public.wiki_page_versions USING btree (wiki_page_id);


--
-- Name: index_wiki_pages_on_body_index_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_body_index_index ON public.wiki_pages USING gin (body_index);


--
-- Name: index_wiki_pages_on_other_names; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_other_names ON public.wiki_pages USING gin (other_names);


--
-- Name: index_wiki_pages_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_wiki_pages_on_title ON public.wiki_pages USING btree (title);


--
-- Name: index_wiki_pages_on_title_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_title_pattern ON public.wiki_pages USING btree (title text_pattern_ops);


--
-- Name: index_wiki_pages_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_updated_at ON public.wiki_pages USING btree (updated_at);


--
-- Name: comments trigger_comments_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_comments_on_update BEFORE INSERT OR UPDATE ON public.comments FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('body_index', 'pg_catalog.english', 'body');


--
-- Name: dmails trigger_dmails_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_dmails_on_update BEFORE INSERT OR UPDATE ON public.dmails FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('message_index', 'pg_catalog.english', 'title', 'body');


--
-- Name: forum_posts trigger_forum_posts_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_forum_posts_on_update BEFORE INSERT OR UPDATE ON public.forum_posts FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('text_index', 'pg_catalog.english', 'body');


--
-- Name: forum_topics trigger_forum_topics_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_forum_topics_on_update BEFORE INSERT OR UPDATE ON public.forum_topics FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('text_index', 'pg_catalog.english', 'title');


--
-- Name: notes trigger_notes_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_notes_on_update BEFORE INSERT OR UPDATE ON public.notes FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('body_index', 'pg_catalog.english', 'body');


--
-- Name: posts trigger_posts_on_tag_index_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_posts_on_tag_index_update BEFORE INSERT OR UPDATE ON public.posts FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('tag_index', 'public.danbooru', 'tag_string', 'fav_string', 'pool_string');


--
-- Name: wiki_pages trigger_wiki_pages_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_wiki_pages_on_update BEFORE INSERT OR UPDATE ON public.wiki_pages FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('body_index', 'public.danbooru', 'body', 'title');


--
-- Name: favorites fk_rails_a7668ef613; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT fk_rails_a7668ef613 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: favorites fk_rails_d20e53bb68; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT fk_rails_d20e53bb68 FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20100204211522'),
('20100204214746'),
('20100205162521'),
('20100205163027'),
('20100205224030'),
('20100211025616'),
('20100211181944'),
('20100211191709'),
('20100211191716'),
('20100213181847'),
('20100213183712'),
('20100214080549'),
('20100214080557'),
('20100214080605'),
('20100215182234'),
('20100215213756'),
('20100215223541'),
('20100215224629'),
('20100215224635'),
('20100215225710'),
('20100215230642'),
('20100219230537'),
('20100221003655'),
('20100221005812'),
('20100223001012'),
('20100224171915'),
('20100224172146'),
('20100307073438'),
('20100309211553'),
('20100318213503'),
('20100826232512'),
('20110328215652'),
('20110328215701'),
('20110607194023'),
('20110717010705'),
('20110722211855'),
('20110815233456'),
('20111101212358'),
('20130106210658'),
('20130114154400'),
('20130219171111'),
('20130219184743'),
('20130221032344'),
('20130221035518'),
('20130221214811'),
('20130302214500'),
('20130305005138'),
('20130307225324'),
('20130308204213'),
('20130318002652'),
('20130318012517'),
('20130318030619'),
('20130318231740'),
('20130320070700'),
('20130322162059'),
('20130322173202'),
('20130322173859'),
('20130323160259'),
('20130326035904'),
('20130328092739'),
('20130331180246'),
('20130331182719'),
('20130401013601'),
('20130409191950'),
('20130417221643'),
('20130424121410'),
('20130506154136'),
('20130606224559'),
('20130618230158'),
('20130620215658'),
('20130712162600'),
('20130914175431'),
('20131006193238'),
('20131117150705'),
('20131118153503'),
('20131130190411'),
('20131209181023'),
('20131217025233'),
('20131225002748'),
('20140111191413'),
('20140204233337'),
('20140221213349'),
('20140428015134'),
('20140505000956'),
('20140603225334'),
('20140604002414'),
('20140613004559'),
('20140701224800'),
('20140722225753'),
('20140725003232'),
('20141009231234'),
('20141017231608'),
('20141120045943'),
('20150119191042'),
('20150120005624'),
('20150128005954'),
('20150403224949'),
('20150613010904'),
('20150623191904'),
('20150629235905'),
('20150705014135'),
('20150721214646'),
('20150728170433'),
('20150805010245'),
('20151217213321'),
('20160219004022'),
('20160219010854'),
('20160219172840'),
('20160222211328'),
('20160526174848'),
('20160820003534'),
('20160822230752'),
('20160919234407'),
('20161018221128'),
('20161024220345'),
('20161101003139'),
('20161221225849'),
('20161227003428'),
('20161229001201'),
('20170106012138'),
('20170112021922'),
('20170112060921'),
('20170117233040'),
('20170218104710'),
('20170302014435'),
('20170314235626'),
('20170316224630'),
('20170319000519'),
('20170329185605'),
('20170330230231'),
('20170413000209'),
('20170414005856'),
('20170414233426'),
('20170414233617'),
('20170416224142'),
('20170428220448'),
('20170512221200'),
('20170515235205'),
('20170519204506'),
('20170526183928'),
('20170608043651'),
('20170613200356'),
('20170709190409'),
('20170914200122'),
('20171106075030'),
('20171127195124'),
('20171218213037'),
('20171219001521'),
('20171230220225'),
('20180113211343'),
('20180116001101'),
('20180403231351'),
('20180413224239'),
('20180425194016'),
('20180516222413'),
('20180517190048'),
('20180518175154'),
('20180804203201'),
('20180816230604'),
('20180912185624'),
('20180913184128'),
('20180916002448'),
('20181108162204'),
('20181108205842'),
('20181113174914'),
('20181114180205'),
('20181114185032'),
('20181114202744'),
('20181130004740'),
('20181202172145'),
('20190109210822'),
('20190129012253'),
('20190202155518'),
('20190206023508'),
('20190209212716'),
('20190214040324'),
('20190214090126'),
('20190220025517');


