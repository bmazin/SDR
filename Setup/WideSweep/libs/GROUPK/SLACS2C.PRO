;+
;*  - - - - - - - -
;*   s l a C s 2 c
;*  - - - - - - - -
;*
;*  Spherical coordinates to direction cosines.
;*
;*  (single precision)
;*
;*  Given:
;*     a,b      float     spherical coordinates in radians
;*                        (RA,Dec), (long,lat) etc
;*
;*  Returned:
;*     v        float[3]  x,y,z unit vector
;*
;*  The spherical coordinates are longitude (+ve anticlockwise
;*  looking from the +ve latitude pole) and latitude.  The
;*  Cartesian coordinates are right handed, with the x axis
;*  at zero longitude and latitude, and the z axis at the
;*  +ve latitude pole.
;*
;*  P.T.Wallace   Starlink   31 October 1993
;-
pro slaCs2c, a, b, v

   n    = N_ELEMENTS( a )
   cosb = float( cos( b ) )
   v    = fltarr(3,n)
   v(0,*) = float( cos ( a ) * cosb )
   v(1,*) = float( sin ( a ) * cosb )
   v(2,*) = float( sin ( b ) )

end
