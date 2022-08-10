-- DROP FUNCTION public.st_convergence(double precision, double precision, text);

CREATE OR REPLACE FUNCTION public.st_convergence(x double precision, y double precision, epsg text)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT COST 50
AS '$libdir/pg_custom_plugins',  $function$get_grid_convergence$function$
;

COMMENT ON FUNCTION public.st_convergence(double precision, double precision, text) IS 'args: x-coodrinate, y-coordinate, srid in format EPSG:XXXX - Returns Grid convergence value in degrees.';

--select st_convergence(263114.612, 6650955.438,'EPSG:25833'); -- returns: -3.6706563582038396



-- DROP FUNCTION public.st_convergence(geometry);

CREATE OR REPLACE FUNCTION public.st_convergence(geometry)
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
		
		return public.st_convergence(st_x(st_centroid($1)),st_y(st_centroid($1)),'EPSG:'::text || st_srid($1)::text);
	END  
$function$;
COMMENT ON FUNCTION public.st_convergence(geometry) IS 'args: a_pointgeometry - Returns Grid convergence value in degrees.';

-- select st_convergence(st_setsrid(st_makepoint(263114.612, 6650955.438), 25833)); -- returns: -3.6706563582038396
-- select st_convergence(st_setsrid(st_makepoint(10, 55), 4326)); -- retuns: 0
