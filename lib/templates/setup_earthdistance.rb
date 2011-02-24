class SetupEarthdistance < ActiveRecord::Migration
  def self.up
    sql = <<-EARTHDISTANCE_SQL
/* $PostgreSQL: pgsql/contrib/cube/cube.sql.in,v 1.25 2009/06/11 18:30:03 tgl Exp $ */

-- Adjust this setting to control where the objects get created.
SET search_path = public;

-- Create the user-defined type for N-dimensional boxes
-- 

CREATE OR REPLACE FUNCTION cube_in(cstring)
RETURNS cube
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION cube(float8[], float8[]) RETURNS cube
AS '$libdir/cube', 'cube_a_f8_f8'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION cube(float8[]) RETURNS cube
AS '$libdir/cube', 'cube_a_f8'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION cube_out(cube)
RETURNS cstring
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE cube (
INTERNALLENGTH = variable,
INPUT = cube_in,
OUTPUT = cube_out,
ALIGNMENT = double
);

COMMENT ON TYPE cube IS 'multi-dimensional cube ''(FLOAT-1, FLOAT-2, ..., FLOAT-N), (FLOAT-1, FLOAT-2, ..., FLOAT-N)''';

--
-- External C-functions for R-tree methods
--

-- Comparison methods

CREATE OR REPLACE FUNCTION cube_eq(cube, cube)
RETURNS bool
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

COMMENT ON FUNCTION cube_eq(cube, cube) IS 'same as';

CREATE OR REPLACE FUNCTION cube_ne(cube, cube)
RETURNS bool
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

COMMENT ON FUNCTION cube_ne(cube, cube) IS 'different';

CREATE OR REPLACE FUNCTION cube_lt(cube, cube)
RETURNS bool
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

COMMENT ON FUNCTION cube_lt(cube, cube) IS 'lower than';

CREATE OR REPLACE FUNCTION cube_gt(cube, cube)
RETURNS bool
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

COMMENT ON FUNCTION cube_gt(cube, cube) IS 'greater than';

CREATE OR REPLACE FUNCTION cube_le(cube, cube)
RETURNS bool
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

COMMENT ON FUNCTION cube_le(cube, cube) IS 'lower than or equal to';

CREATE OR REPLACE FUNCTION cube_ge(cube, cube)
RETURNS bool
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

COMMENT ON FUNCTION cube_ge(cube, cube) IS 'greater than or equal to';

CREATE OR REPLACE FUNCTION cube_cmp(cube, cube)
RETURNS int4
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

COMMENT ON FUNCTION cube_cmp(cube, cube) IS 'btree comparison function';

CREATE OR REPLACE FUNCTION cube_contains(cube, cube)
RETURNS bool
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

COMMENT ON FUNCTION cube_contains(cube, cube) IS 'contains';

CREATE OR REPLACE FUNCTION cube_contained(cube, cube)
RETURNS bool
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

COMMENT ON FUNCTION cube_contained(cube, cube) IS 'contained in';

CREATE OR REPLACE FUNCTION cube_overlap(cube, cube)
RETURNS bool
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

COMMENT ON FUNCTION cube_overlap(cube, cube) IS 'overlaps';

-- support routines for indexing

CREATE OR REPLACE FUNCTION cube_union(cube, cube)
RETURNS cube
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION cube_inter(cube, cube)
RETURNS cube
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION cube_size(cube)
RETURNS float8
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;


-- Misc N-dimensional functions

CREATE OR REPLACE FUNCTION cube_subset(cube, int4[])
RETURNS cube
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

-- proximity routines

CREATE OR REPLACE FUNCTION cube_distance(cube, cube)
RETURNS float8
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

-- Extracting elements functions

CREATE OR REPLACE FUNCTION cube_dim(cube)
RETURNS int4
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION cube_ll_coord(cube, int4)
RETURNS float8
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION cube_ur_coord(cube, int4)
RETURNS float8
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION cube(float8) RETURNS cube
AS '$libdir/cube', 'cube_f8'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION cube(float8, float8) RETURNS cube
AS '$libdir/cube', 'cube_f8_f8'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION cube(cube, float8) RETURNS cube
AS '$libdir/cube', 'cube_c_f8'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION cube(cube, float8, float8) RETURNS cube
AS '$libdir/cube', 'cube_c_f8_f8'
LANGUAGE C IMMUTABLE STRICT;

-- Test if cube is also a point

CREATE OR REPLACE FUNCTION cube_is_point(cube)
RETURNS bool
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

-- Increasing the size of a cube by a radius in at least n dimensions

CREATE OR REPLACE FUNCTION cube_enlarge(cube, float8, int4)
RETURNS cube
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

--
-- OPERATORS
--

CREATE OPERATOR < (
LEFTARG = cube, RIGHTARG = cube, PROCEDURE = cube_lt,
COMMUTATOR = '>', NEGATOR = '>=',
RESTRICT = scalarltsel, JOIN = scalarltjoinsel
);

CREATE OPERATOR > (
LEFTARG = cube, RIGHTARG = cube, PROCEDURE = cube_gt,
COMMUTATOR = '<', NEGATOR = '<=',
RESTRICT = scalargtsel, JOIN = scalargtjoinsel
);

CREATE OPERATOR <= (
LEFTARG = cube, RIGHTARG = cube, PROCEDURE = cube_le,
COMMUTATOR = '>=', NEGATOR = '>',
RESTRICT = scalarltsel, JOIN = scalarltjoinsel
);

CREATE OPERATOR >= (
LEFTARG = cube, RIGHTARG = cube, PROCEDURE = cube_ge,
COMMUTATOR = '<=', NEGATOR = '<',
RESTRICT = scalargtsel, JOIN = scalargtjoinsel
);

CREATE OPERATOR && (
LEFTARG = cube, RIGHTARG = cube, PROCEDURE = cube_overlap,
COMMUTATOR = '&&',
RESTRICT = areasel, JOIN = areajoinsel
);

CREATE OPERATOR = (
LEFTARG = cube, RIGHTARG = cube, PROCEDURE = cube_eq,
COMMUTATOR = '=', NEGATOR = '<>',
RESTRICT = eqsel, JOIN = eqjoinsel,
MERGES
);

CREATE OPERATOR <> (
LEFTARG = cube, RIGHTARG = cube, PROCEDURE = cube_ne,
COMMUTATOR = '<>', NEGATOR = '=',
RESTRICT = neqsel, JOIN = neqjoinsel
);

CREATE OPERATOR @> (
LEFTARG = cube, RIGHTARG = cube, PROCEDURE = cube_contains,
COMMUTATOR = '<@',
RESTRICT = contsel, JOIN = contjoinsel
);

CREATE OPERATOR <@ (
LEFTARG = cube, RIGHTARG = cube, PROCEDURE = cube_contained,
COMMUTATOR = '@>',
RESTRICT = contsel, JOIN = contjoinsel
);

-- these are obsolete/deprecated:
CREATE OPERATOR @ (
LEFTARG = cube, RIGHTARG = cube, PROCEDURE = cube_contains,
COMMUTATOR = '~',
RESTRICT = contsel, JOIN = contjoinsel
);

CREATE OPERATOR ~ (
LEFTARG = cube, RIGHTARG = cube, PROCEDURE = cube_contained,
COMMUTATOR = '@',
RESTRICT = contsel, JOIN = contjoinsel
);


-- define the GiST support methods
CREATE OR REPLACE FUNCTION g_cube_consistent(internal,cube,int,oid,internal)
RETURNS bool
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION g_cube_compress(internal)
RETURNS internal 
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION g_cube_decompress(internal)
RETURNS internal 
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION g_cube_penalty(internal,internal,internal)
RETURNS internal
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION g_cube_picksplit(internal, internal)
RETURNS internal
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION g_cube_union(internal, internal)
RETURNS cube 
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION g_cube_same(cube, cube, internal)
RETURNS internal 
AS '$libdir/cube'
LANGUAGE C IMMUTABLE STRICT;


-- Create the operator classes for indexing

CREATE OPERATOR CLASS cube_ops
  DEFAULT FOR TYPE cube USING btree AS
      OPERATOR        1       < ,
      OPERATOR        2       <= ,
      OPERATOR        3       = ,
      OPERATOR        4       >= ,
      OPERATOR        5       > ,
      FUNCTION        1       cube_cmp(cube, cube);

CREATE OPERATOR CLASS gist_cube_ops
  DEFAULT FOR TYPE cube USING gist AS
OPERATOR	3	&& ,
OPERATOR	6	= ,
OPERATOR	7	@> ,
OPERATOR	8	<@ ,
OPERATOR	13	@ ,
OPERATOR	14	~ ,
FUNCTION	1	g_cube_consistent (internal, cube, int, oid, internal),
FUNCTION	2	g_cube_union (internal, internal),
FUNCTION	3	g_cube_compress (internal),
FUNCTION	4	g_cube_decompress (internal),
FUNCTION	5	g_cube_penalty (internal, internal, internal),
FUNCTION	6	g_cube_picksplit (internal, internal),
FUNCTION	7	g_cube_same (cube, cube, internal);



/* $PostgreSQL: pgsql/contrib/earthdistance/earthdistance.sql.in,v 1.11 2007/11/13 04:24:27 momjian Exp $ */

-- Adjust this setting to control where the objects get created.
SET search_path = public;

-- The earth functions rely on contrib/cube having been installed and loaded.

-- earth() returns the radius of the earth in meters. This is the only
-- place you need to change things for the cube base distance functions
-- in order to use different units (or a better value for the Earth's radius).

CREATE OR REPLACE FUNCTION earth() RETURNS float8
LANGUAGE SQL IMMUTABLE
AS 'SELECT ''6378168''::float8';

-- Astromers may want to change the earth function so that distances will be
-- returned in degrees. To do this comment out the above definition and
-- uncomment the one below. Note that doing this will break the regression
-- tests.
--
-- CREATE OR REPLACE FUNCTION earth() RETURNS float8
-- LANGUAGE SQL IMMUTABLE
-- AS 'SELECT 180/pi()';

-- Define domain for locations on the surface of the earth using a cube
-- datatype with constraints. cube provides 3D indexing.
-- The cube is restricted to be a point, no more than 3 dimensions
-- (for less than 3 dimensions 0 is assumed for the missing coordinates)
-- and that the point must be very near the surface of the sphere
-- centered about the origin with the radius of the earth.

CREATE DOMAIN earth AS cube
  CONSTRAINT not_point check(cube_is_point(value))
  CONSTRAINT not_3d check(cube_dim(value) <= 3)
  CONSTRAINT on_surface check(abs(cube_distance(value, '(0)'::cube) /
  earth() - 1) < '10e-7'::float8);

CREATE OR REPLACE FUNCTION sec_to_gc(float8) 
RETURNS float8
LANGUAGE SQL
IMMUTABLE STRICT
AS 'SELECT CASE WHEN $1 < 0 THEN 0::float8 WHEN $1/(2*earth()) > 1 THEN pi()*earth() ELSE 2*earth()*asin($1/(2*earth())) END';

CREATE OR REPLACE FUNCTION gc_to_sec(float8)
RETURNS float8
LANGUAGE SQL
IMMUTABLE STRICT
AS 'SELECT CASE WHEN $1 < 0 THEN 0::float8 WHEN $1/earth() > pi() THEN 2*earth() ELSE 2*earth()*sin($1/(2*earth())) END';

CREATE OR REPLACE FUNCTION ll_to_earth(float8, float8)
RETURNS earth
LANGUAGE SQL
IMMUTABLE STRICT
AS 'SELECT cube(cube(cube(earth()*cos(radians($1))*cos(radians($2))),earth()*cos(radians($1))*sin(radians($2))),earth()*sin(radians($1)))::earth';

CREATE OR REPLACE FUNCTION latitude(earth)
RETURNS float8
LANGUAGE SQL
IMMUTABLE STRICT
AS 'SELECT CASE WHEN cube_ll_coord($1, 3)/earth() < -1 THEN -90::float8 WHEN cube_ll_coord($1, 3)/earth() > 1 THEN 90::float8 ELSE degrees(asin(cube_ll_coord($1, 3)/earth())) END';

CREATE OR REPLACE FUNCTION longitude(earth)
RETURNS float8
LANGUAGE SQL
IMMUTABLE STRICT
AS 'SELECT degrees(atan2(cube_ll_coord($1, 2), cube_ll_coord($1, 1)))';

CREATE OR REPLACE FUNCTION earth_distance(earth, earth)
RETURNS float8
LANGUAGE SQL
IMMUTABLE STRICT
AS 'SELECT sec_to_gc(cube_distance($1, $2))';

CREATE OR REPLACE FUNCTION earth_box(earth, float8)
RETURNS cube
LANGUAGE SQL
IMMUTABLE STRICT
AS 'SELECT cube_enlarge($1, gc_to_sec($2), 3)';

--------------- geo_distance

CREATE OR REPLACE FUNCTION geo_distance (point, point)
RETURNS float8
LANGUAGE C IMMUTABLE STRICT AS '$libdir/earthdistance';

--------------- geo_distance as operator <@>

CREATE OPERATOR <@> (
  LEFTARG = point,
  RIGHTARG = point,
  PROCEDURE = geo_distance,
  COMMUTATOR = <@>
);

EARTHDISTANCE_SQL
    execute sql
  end

  def self.down
    # Kinda... hard.
  end
end
