;+
;*  - - - - - - - -
;*   s l a C c 2 s
;*  - - - - - - - -
;*
;*  Direction cosines to spherical coordinates.
;*
;*  (single precision)
;*
;*  Given:
;*     v       float[3]   x,y,z vector
;*
;*  Returned:
;*     *a,*b   float      spherical coordinates in radians
;*
;*  The spherical coordinates are longitude (+ve anticlockwise
;*  looking from the +ve latitude pole) and latitude.  The
;*  Cartesian coordinates are right handed, with the x axis
;*  at zero longitude and latitude, and the z axis at the
;*  +ve latitude pole.
;*
;*  If v is null, zero a and b are returned.
;*  At either pole, zero a is returned.
;*
;*  P.T.Wallace   Starlink   31 October 1993
;-
pro slaCc2s, v, a, b

   x = float( v(0,*) )
   y = float( v(1,*) )
   z = float( v(2,*) )
   r = sqrt( x * x + y * y )
   n = n_elements( r )

   a = fltarr( n )
   b = fltarr( n )

   indices = where( r ne 0.0 )
   a( indices ) = atan( y(indices), x(indices) )

   indices = where( z ne 0.0 )
   b( indices ) = atan( z(indices), r(indices) )

end
