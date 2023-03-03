-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION eyevigis" to load this file. \quit


-- Create C library functions
CREATE FUNCTION st_convergence(x double precision, y double precision, epsg text)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT COST 50
AS 'MODULE_PATHNAME',  $function$get_grid_convergence$function$
;
COMMENT ON FUNCTION st_convergence(double precision, double precision, text) IS 'args: x-coodrinate, y-coordinate, srid in format EPSG:XXXX - Returns Grid convergence value in degrees.';


-- Check if postgis is installed and create functions with PostGIS geometry
DO $$
DECLARE
  postgis_installed int;
  postgis_schema text;
BEGIN
  SELECT count(*) INTO postgis_installed
    FROM pg_catalog.pg_proc p, pg_catalog.pg_namespace n
    WHERE p.proname = 'postgis_version'
    AND p.pronamespace = n.oid;

    IF postgis_installed = 1 THEN
        SELECT nspname into postgis_schema
            FROM pg_catalog.pg_proc p, pg_catalog.pg_namespace n
            WHERE p.proname = 'postgis_version'
            AND p.pronamespace = n.oid;

    EXECUTE FORMAT('SET search_path TO %I;', postgis_schema);

--- ALL FUNCTIONS FOR PG

CREATE OR REPLACE FUNCTION st_convergence(geometry)
 RETURNS double precision
 LANGUAGE plpgsql
 IMMUTABLE PARALLEL SAFE STRICT
AS 
$function$ 
	declare
		srid int;
	begin
		if st_srid($1) = 4326 then
			return 0;
		end if;
		
		return @extschema@.st_convergence(st_x(st_centroid($1)),st_y(st_centroid($1)),'EPSG:'::text || st_srid($1)::text);
	END  
$function$;
COMMENT ON FUNCTION st_convergence(geometry) IS 'args: a_pointgeometry - Returns Grid convergence value in degrees.';

    END IF;
END
$$ LANGUAGE 'plpgsql';

