/* Windows compatibility stubs for SExtractor
 * This file provides missing symbols and functions for Windows compilation
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <math.h>

/* CFITSIO missing symbols */
static float fits_rand_dummy = 0.0f;
float *fits_rand_value = &fits_rand_dummy;

/* sincos function implementation for Windows */
void sincos(double x, double *sin_x, double *cos_x) {
    *sin_x = sin(x);
    *cos_x = cos(x);
}

void sincosf(float x, float *sin_x, float *cos_x) {
    *sin_x = sinf(x);
    *cos_x = cosf(x);
}
