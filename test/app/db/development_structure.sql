--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: -
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpgsql;


SET search_path = public, pg_catalog;

--
-- Name: cube; Type: SHELL TYPE; Schema: public; Owner: -
--

CREATE TYPE cube;


--
-- Name: cube_in(cstring); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_in(cstring) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_in';


--
-- Name: cube_out(cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_out(cube) RETURNS cstring
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_out';


--
-- Name: cube; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE cube (
    INTERNALLENGTH = variable,
    INPUT = cube_in,
    OUTPUT = cube_out,
    ALIGNMENT = double,
    STORAGE = plain
);


--
-- Name: TYPE cube; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TYPE cube IS 'multi-dimensional cube ''(FLOAT-1, FLOAT-2, ..., FLOAT-N), (FLOAT-1, FLOAT-2, ..., FLOAT-N)''';


--
-- Name: cube_dim(cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_dim(cube) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_dim';


--
-- Name: cube_distance(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_distance(cube, cube) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_distance';


--
-- Name: cube_is_point(cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_is_point(cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_is_point';


--
-- Name: earth(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION earth() RETURNS double precision
    LANGUAGE sql IMMUTABLE
    AS $$SELECT '6378168'::float8$$;


--
-- Name: earth; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN earth AS cube
	CONSTRAINT not_3d CHECK ((cube_dim(VALUE) <= 3))
	CONSTRAINT not_point CHECK (cube_is_point(VALUE))
	CONSTRAINT on_surface CHECK ((abs(((cube_distance(VALUE, '(0)'::cube) / earth()) - (1)::double precision)) < 9.99999999999999955e-07::double precision));


--
-- Name: cube(double precision[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube(double precision[]) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_a_f8';


--
-- Name: cube(double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube(double precision) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_f8';


--
-- Name: cube(double precision[], double precision[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube(double precision[], double precision[]) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_a_f8_f8';


--
-- Name: cube(double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube(double precision, double precision) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_f8_f8';


--
-- Name: cube(cube, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube(cube, double precision) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_c_f8';


--
-- Name: cube(cube, double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube(cube, double precision, double precision) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_c_f8_f8';


--
-- Name: cube_cmp(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_cmp(cube, cube) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_cmp';


--
-- Name: FUNCTION cube_cmp(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_cmp(cube, cube) IS 'btree comparison function';


--
-- Name: cube_contained(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_contained(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_contained';


--
-- Name: FUNCTION cube_contained(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_contained(cube, cube) IS 'contained in';


--
-- Name: cube_contains(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_contains(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_contains';


--
-- Name: FUNCTION cube_contains(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_contains(cube, cube) IS 'contains';


--
-- Name: cube_enlarge(cube, double precision, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_enlarge(cube, double precision, integer) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_enlarge';


--
-- Name: cube_eq(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_eq(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_eq';


--
-- Name: FUNCTION cube_eq(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_eq(cube, cube) IS 'same as';


--
-- Name: cube_ge(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_ge(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_ge';


--
-- Name: FUNCTION cube_ge(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_ge(cube, cube) IS 'greater than or equal to';


--
-- Name: cube_gt(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_gt(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_gt';


--
-- Name: FUNCTION cube_gt(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_gt(cube, cube) IS 'greater than';


--
-- Name: cube_inter(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_inter(cube, cube) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_inter';


--
-- Name: cube_le(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_le(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_le';


--
-- Name: FUNCTION cube_le(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_le(cube, cube) IS 'lower than or equal to';


--
-- Name: cube_ll_coord(cube, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_ll_coord(cube, integer) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_ll_coord';


--
-- Name: cube_lt(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_lt(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_lt';


--
-- Name: FUNCTION cube_lt(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_lt(cube, cube) IS 'lower than';


--
-- Name: cube_ne(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_ne(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_ne';


--
-- Name: FUNCTION cube_ne(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_ne(cube, cube) IS 'different';


--
-- Name: cube_overlap(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_overlap(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_overlap';


--
-- Name: FUNCTION cube_overlap(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_overlap(cube, cube) IS 'overlaps';


--
-- Name: cube_size(cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_size(cube) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_size';


--
-- Name: cube_subset(cube, integer[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_subset(cube, integer[]) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_subset';


--
-- Name: cube_union(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_union(cube, cube) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_union';


--
-- Name: cube_ur_coord(cube, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_ur_coord(cube, integer) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_ur_coord';


--
-- Name: earth_box(earth, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION earth_box(earth, double precision) RETURNS cube
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT cube_enlarge($1, gc_to_sec($2), 3)$_$;


--
-- Name: earth_distance(earth, earth); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION earth_distance(earth, earth) RETURNS double precision
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT sec_to_gc(cube_distance($1, $2))$_$;


--
-- Name: g_cube_compress(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION g_cube_compress(internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_compress';


--
-- Name: g_cube_consistent(internal, cube, integer, oid, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION g_cube_consistent(internal, cube, integer, oid, internal) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_consistent';


--
-- Name: g_cube_decompress(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION g_cube_decompress(internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_decompress';


--
-- Name: g_cube_penalty(internal, internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION g_cube_penalty(internal, internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_penalty';


--
-- Name: g_cube_picksplit(internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION g_cube_picksplit(internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_picksplit';


--
-- Name: g_cube_same(cube, cube, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION g_cube_same(cube, cube, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_same';


--
-- Name: g_cube_union(internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION g_cube_union(internal, internal) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_union';


--
-- Name: gc_to_sec(double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gc_to_sec(double precision) RETURNS double precision
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT CASE WHEN $1 < 0 THEN 0::float8 WHEN $1/earth() > pi() THEN 2*earth() ELSE 2*earth()*sin($1/(2*earth())) END$_$;


--
-- Name: geo_distance(point, point); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION geo_distance(point, point) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/earthdistance', 'geo_distance';


--
-- Name: latitude(earth); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION latitude(earth) RETURNS double precision
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT CASE WHEN cube_ll_coord($1, 3)/earth() < -1 THEN -90::float8 WHEN cube_ll_coord($1, 3)/earth() > 1 THEN 90::float8 ELSE degrees(asin(cube_ll_coord($1, 3)/earth())) END$_$;


--
-- Name: ll_to_earth(double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ll_to_earth(double precision, double precision) RETURNS earth
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT cube(cube(cube(earth()*cos(radians($1))*cos(radians($2))),earth()*cos(radians($1))*sin(radians($2))),earth()*sin(radians($1)))::earth$_$;


--
-- Name: longitude(earth); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION longitude(earth) RETURNS double precision
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT degrees(atan2(cube_ll_coord($1, 2), cube_ll_coord($1, 1)))$_$;


--
-- Name: sec_to_gc(double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sec_to_gc(double precision) RETURNS double precision
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT CASE WHEN $1 < 0 THEN 0::float8 WHEN $1/(2*earth()) > 1 THEN pi()*earth() ELSE 2*earth()*asin($1/(2*earth())) END$_$;


--
-- Name: &&; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR && (
    PROCEDURE = cube_overlap,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = &&,
    RESTRICT = areasel,
    JOIN = areajoinsel
);


--
-- Name: <; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR < (
    PROCEDURE = cube_lt,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = >,
    NEGATOR = >=,
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);


--
-- Name: <=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR <= (
    PROCEDURE = cube_le,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = >=,
    NEGATOR = >,
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);


--
-- Name: <>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR <> (
    PROCEDURE = cube_ne,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = <>,
    NEGATOR = =,
    RESTRICT = neqsel,
    JOIN = neqjoinsel
);


--
-- Name: <@; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR <@ (
    PROCEDURE = cube_contained,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = @>,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: <@>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR <@> (
    PROCEDURE = geo_distance,
    LEFTARG = point,
    RIGHTARG = point,
    COMMUTATOR = <@>
);


--
-- Name: =; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR = (
    PROCEDURE = cube_eq,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = =,
    NEGATOR = <>,
    MERGES,
    RESTRICT = eqsel,
    JOIN = eqjoinsel
);


--
-- Name: >; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR > (
    PROCEDURE = cube_gt,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = <,
    NEGATOR = <=,
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);


--
-- Name: >=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR >= (
    PROCEDURE = cube_ge,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = <=,
    NEGATOR = <,
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);


--
-- Name: @; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR @ (
    PROCEDURE = cube_contains,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = ~,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: @>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR @> (
    PROCEDURE = cube_contains,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = <@,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: ~; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR ~ (
    PROCEDURE = cube_contained,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = @,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: cube_ops; Type: OPERATOR CLASS; Schema: public; Owner: -
--

CREATE OPERATOR CLASS cube_ops
    DEFAULT FOR TYPE cube USING btree AS
    OPERATOR 1 <(cube,cube) ,
    OPERATOR 2 <=(cube,cube) ,
    OPERATOR 3 =(cube,cube) ,
    OPERATOR 4 >=(cube,cube) ,
    OPERATOR 5 >(cube,cube) ,
    FUNCTION 1 cube_cmp(cube,cube);


--
-- Name: gist_cube_ops; Type: OPERATOR CLASS; Schema: public; Owner: -
--

CREATE OPERATOR CLASS gist_cube_ops
    DEFAULT FOR TYPE cube USING gist AS
    OPERATOR 3 &&(cube,cube) ,
    OPERATOR 6 =(cube,cube) ,
    OPERATOR 7 @>(cube,cube) ,
    OPERATOR 8 <@(cube,cube) ,
    OPERATOR 13 @(cube,cube) ,
    OPERATOR 14 ~(cube,cube) ,
    FUNCTION 1 g_cube_consistent(internal,cube,integer,oid,internal) ,
    FUNCTION 2 g_cube_union(internal,internal) ,
    FUNCTION 3 g_cube_compress(internal) ,
    FUNCTION 4 g_cube_decompress(internal) ,
    FUNCTION 5 g_cube_penalty(internal,internal,internal) ,
    FUNCTION 6 g_cube_picksplit(internal,internal) ,
    FUNCTION 7 g_cube_same(cube,cube,internal);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: places; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE places (
    id integer NOT NULL,
    lt double precision,
    lg double precision,
    lat double precision,
    lng double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: places_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE places_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: places_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE places_id_seq OWNED BY places.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE places ALTER COLUMN id SET DEFAULT nextval('places_id_seq'::regclass);


--
-- Name: places_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY places
    ADD CONSTRAINT places_pkey PRIMARY KEY (id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20110225205046');

INSERT INTO schema_migrations (version) VALUES ('20110225205131');