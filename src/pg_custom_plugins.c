#include "postgres.h"
#include "fmgr.h"
#include "utils/builtins.h"

#include <proj.h>

PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(get_grid_convergence);
Datum get_grid_convergence(PG_FUNCTION_ARGS)
{
	double pX, pY, convergence = 0;
    char   *epsg;
    
    PJ_CONTEXT *C;
    PJ *P, *P2;
    PJ *norm;
    PJ_COORD a, b;

	pX = PG_GETARG_FLOAT8(0);
	pY = PG_GETARG_FLOAT8(1);
    epsg = text_to_cstring(PG_GETARG_TEXT_P(2));

	if (PG_NARGS() == 3){
		
        // or you may set C=PJ_DEFAULT_CTX if you are sure you will     
        // use PJ objects from only one thread                          
        //C = proj_context_create();
        C=PJ_DEFAULT_CTX;

        P = proj_create_crs_to_crs (C, epsg, "EPSG:4326", NULL);

        if (0 == P) {
            elog(ERROR, "Failed to create transformation object.\n");
            PG_RETURN_NULL();
        }

        norm = proj_normalize_for_visualization(C, P);
        if (0 == norm) {
            elog(ERROR, "Failed to normalize transformation object.\n");
            PG_RETURN_NULL();
        }
        proj_destroy(P);
        P = norm;

        a = proj_coord(pX, pY, 0, 0);
        b = proj_trans(P, PJ_FWD, a);
        //printf("lat/lon: %.6f, %.6f\n", b.enu.e, b.enu.n);

        P2 = proj_get_source_crs(C, P);
        if (0 == P2) {
            elog(ERROR, "Failed to create transformation object.\n");
            PG_RETURN_NULL();
        }

        // proj_factors wants these values in radians
        b.lp.lam = proj_torad(b.enu.e);
        b.lp.phi = proj_torad(b.enu.n);

        PJ_FACTORS factors = proj_factors(P2, b);
        convergence = proj_todeg(factors.meridian_convergence);
        
        proj_destroy(P);
        proj_destroy(P2);
        proj_context_destroy(C);

	}
	else
	{
		elog(ERROR, "st_convergence: unsupported number of args: %d", PG_NARGS());
		PG_RETURN_NULL();
	}

	PG_RETURN_FLOAT8(convergence);
}
