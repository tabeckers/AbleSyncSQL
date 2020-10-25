--
-- PostgreSQL database dump
--

-- Dumped from database version 12.4 (Ubuntu 12.4-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.4 (Ubuntu 12.4-0ubuntu0.20.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: entities; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA entities;


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: audio_format; Type: TYPE; Schema: entities; Owner: -
--

CREATE TYPE entities.audio_format AS ENUM (
    'mp3',
    'wav',
    'flac'
);


--
-- Name: project_status; Type: TYPE; Schema: entities; Owner: -
--

CREATE TYPE entities.project_status AS ENUM (
    'created',
    'up_to_date',
    'pending_actions',
    'invalid'
);


--
-- Name: project_task_status; Type: TYPE; Schema: entities; Owner: -
--

CREATE TYPE entities.project_task_status AS ENUM (
    'created',
    'processing',
    'done',
    'failed'
);


--
-- Name: project_task_type; Type: TYPE; Schema: entities; Owner: -
--

CREATE TYPE entities.project_task_type AS ENUM (
    'upload_audio',
    'backup_full'
);


--
-- Name: trigger_date_created(); Type: FUNCTION; Schema: entities; Owner: -
--

CREATE FUNCTION entities.trigger_date_created() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	NEW.date_created = now();
	RETURN NEW;
END
$$;


--
-- Name: trigger_date_updated(); Type: FUNCTION; Schema: entities; Owner: -
--

CREATE FUNCTION entities.trigger_date_updated() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
	NEW.date_updated = now();
	RETURN NEW;
END
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: artist; Type: TABLE; Schema: entities; Owner: -
--

CREATE TABLE entities.artist (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    date_created timestamp with time zone DEFAULT now() NOT NULL,
    date_updated timestamp with time zone
);


--
-- Name: audio_file; Type: TABLE; Schema: entities; Owner: -
--

CREATE TABLE entities.audio_file (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    project_id uuid NOT NULL,
    name text NOT NULL,
    audio_format entities.audio_format NOT NULL,
    date_created timestamp with time zone DEFAULT now(),
    date_updated timestamp with time zone,
    date_synced timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: project; Type: TABLE; Schema: entities; Owner: -
--

CREATE TABLE entities.project (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    artist_id uuid,
    relative_path text NOT NULL,
    date_created timestamp with time zone DEFAULT now() NOT NULL,
    date_updated timestamp with time zone,
    project_status entities.project_status DEFAULT 'created'::entities.project_status NOT NULL
);


--
-- Name: project_task; Type: TABLE; Schema: entities; Owner: -
--

CREATE TABLE entities.project_task (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    project_id uuid NOT NULL,
    date_created timestamp with time zone DEFAULT now() NOT NULL,
    date_updated timestamp with time zone,
    date_completed timestamp with time zone,
    project_task_status entities.project_task_status DEFAULT 'created'::entities.project_task_status NOT NULL,
    project_task_type entities.project_task_type NOT NULL,
    task_parameter text
);


--
-- Name: artist artist_pk; Type: CONSTRAINT; Schema: entities; Owner: -
--

ALTER TABLE ONLY entities.artist
    ADD CONSTRAINT artist_pk PRIMARY KEY (id);


--
-- Name: audio_file audio_file_pkey; Type: CONSTRAINT; Schema: entities; Owner: -
--

ALTER TABLE ONLY entities.audio_file
    ADD CONSTRAINT audio_file_pkey PRIMARY KEY (id);


--
-- Name: project project_pk; Type: CONSTRAINT; Schema: entities; Owner: -
--

ALTER TABLE ONLY entities.project
    ADD CONSTRAINT project_pk PRIMARY KEY (id);


--
-- Name: project_task project_task_pkey; Type: CONSTRAINT; Schema: entities; Owner: -
--

ALTER TABLE ONLY entities.project_task
    ADD CONSTRAINT project_task_pkey PRIMARY KEY (id);


--
-- Name: project_artist_idx; Type: INDEX; Schema: entities; Owner: -
--

CREATE INDEX project_artist_idx ON entities.project USING btree (artist_id);


--
-- Name: project_task_project_idx; Type: INDEX; Schema: entities; Owner: -
--

CREATE INDEX project_task_project_idx ON entities.project_task USING btree (project_id);


--
-- Name: artist artist_trigger_date_created; Type: TRIGGER; Schema: entities; Owner: -
--

CREATE TRIGGER artist_trigger_date_created BEFORE INSERT ON entities.artist FOR EACH ROW EXECUTE FUNCTION entities.trigger_date_created();


--
-- Name: artist artist_trigger_date_updated; Type: TRIGGER; Schema: entities; Owner: -
--

CREATE TRIGGER artist_trigger_date_updated AFTER UPDATE ON entities.artist FOR EACH ROW EXECUTE FUNCTION entities.trigger_date_updated();


--
-- Name: audio_file audio_file_trigger_date_updated; Type: TRIGGER; Schema: entities; Owner: -
--

CREATE TRIGGER audio_file_trigger_date_updated BEFORE UPDATE ON entities.audio_file FOR EACH ROW EXECUTE FUNCTION entities.trigger_date_updated();


--
-- Name: project_task project_task_trigger_created; Type: TRIGGER; Schema: entities; Owner: -
--

CREATE TRIGGER project_task_trigger_created BEFORE INSERT ON entities.project_task FOR EACH ROW EXECUTE FUNCTION entities.trigger_date_created();


--
-- Name: project_task project_task_trigger_updated; Type: TRIGGER; Schema: entities; Owner: -
--

CREATE TRIGGER project_task_trigger_updated AFTER UPDATE ON entities.project_task FOR EACH ROW EXECUTE FUNCTION entities.trigger_date_updated();


--
-- Name: project project_trigger_date_created; Type: TRIGGER; Schema: entities; Owner: -
--

CREATE TRIGGER project_trigger_date_created AFTER UPDATE ON entities.project FOR EACH ROW EXECUTE FUNCTION entities.trigger_date_created();


--
-- Name: project project_trigger_date_updated; Type: TRIGGER; Schema: entities; Owner: -
--

CREATE TRIGGER project_trigger_date_updated BEFORE UPDATE ON entities.project FOR EACH ROW EXECUTE FUNCTION entities.trigger_date_updated();


--
-- Name: audio_file audio_file_project_id_fkey; Type: FK CONSTRAINT; Schema: entities; Owner: -
--

ALTER TABLE ONLY entities.audio_file
    ADD CONSTRAINT audio_file_project_id_fkey FOREIGN KEY (project_id) REFERENCES entities.project(id);


--
-- Name: project project_artist_fk; Type: FK CONSTRAINT; Schema: entities; Owner: -
--

ALTER TABLE ONLY entities.project
    ADD CONSTRAINT project_artist_fk FOREIGN KEY (artist_id) REFERENCES entities.artist(id);


--
-- Name: project_task project_task_project_fk; Type: FK CONSTRAINT; Schema: entities; Owner: -
--

ALTER TABLE ONLY entities.project_task
    ADD CONSTRAINT project_task_project_fk FOREIGN KEY (project_id) REFERENCES entities.project(id);


--
-- PostgreSQL database dump complete
--

