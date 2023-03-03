-- DROP FUNCTION public.st_convergence(double precision, double precision, text);

CREATE OR REPLACE FUNCTION public.st_convergence(x double precision, y double precision, epsg text)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT COST 50
AS '$libdir/pg_eyevigis',  $function$get_grid_convergence$function$
;

COMMENT ON FUNCTION public.st_convergence(double precision, double precision, text) IS 'args: x-coodrinate, y-coordinate, srid in format EPSG:XXXX - Returns Grid convergence value in degrees.';

-- select st_convergence(10, 55, 'EPSG:4326') = 0;
-- select st_convergence(263114.612, 6650955.438,'EPSG:25833') = -3.6706563582038396;
-- select st_convergence(660279.65, 6476095.67,'EPSG:3301') = 2.3419177222973153;
-- select st_convergence(660279.65, 6476095.67,'+proj=lcc +lat_0=57.5175539305556 +lon_0=24 +lat_1=59.3333333333333 +lat_2=58 +x_0=500000 +y_0=6375000 +ellps=GRS80 +units=m +no_defs +type=crs')
-- select st_convergence(484902.59, 6472807.60,'EPSG:32635') = -0.21996779991917292;
-- select st_convergence(170370.71, 11572.40,'EPSG:27700') = -2.453306220041052;


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

-- select st_convergence(st_setsrid(st_makepoint(10, 55), 4326)) = 0;
-- select st_convergence(st_setsrid(st_makepoint(263114.612, 6650955.438), 25833)) = -3.6706563582038396;
-- select st_convergence(st_setsrid(st_makepoint(660279.65, 6476095.67), 3301)) = 2.3419177222973153;
-- select st_convergence(st_setsrid(st_makepoint(484902.59, 6472807.60), 32635)) = -0.21996779991917292;
-- select st_convergence(st_setsrid(st_makepoint(170370.71, 11572.40), 27700)) = -2.453306220041052;

