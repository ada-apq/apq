/* $Id: nmain.c,v 1.5 2002/08/04 23:34:07 wwg Exp $
 * Copyright (C) 2002, Warren W. Gay VE3WWG
 *
 * Licensed under the ACL (Ada Community License)
 * or
 * GNU Public License 2 (GPL2)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */
#include <stdio.h>
#include <stdlib.h>
#include "decimal.h"

int
main(int argc,char **argv) {
	int rscale = numeric_global_rscale();

	puts("nmain started.. division");

	{
		Numeric a, b, r;
		Decimal_Exception ex;

		a = numeric_in("16.0",0,0,&ex);
		printf("a ex = %d\n",ex);
		b = numeric_in("0.6",0,0,&ex);
		printf("b ex = %d\n",ex);

		r = numeric_div(a,b,&rscale,&ex);
		
		printf("r ex = %d\n",ex);

		printf("'%s' / '%s' => '%s' (%s)\n",
			numeric_out(a),
			numeric_out(b),
			numeric_out(r),
			numeric_isnan(r) ? "NaN" : "OK");
		free(a);
		free(b);
		free(r);
	}
	puts("sqrt..");
	{
		Numeric a, r;
		Decimal_Exception ex;

		a = numeric_in("16.374239828239472974978290E09",0,0,&ex);
		printf("a ex = %d\n",ex);
		r = numeric_sqrt(a,&rscale,&ex);
		printf("r ex = %d\n",ex);

		printf("'%s' sqrt => '%s' (%s)\n",
			numeric_out(a),
			numeric_out(r),
			numeric_isnan(r) ? "NaN" : "OK");
		free(a);
		free(r);
	}
	puts("nmain ended.");
	return 0;
}

/* End $Source: /cvsroot/apq/apq/nmain.c,v $ */
