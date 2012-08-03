;+
;     - - - - - - -
;      D E U L E R
;     - - - - - - -
;
;  Form a rotation matrix from the Euler angles - three successive
;  rotations about specified Cartesian axes (double precision)
;
;  Given:
;    ORDER  c*(*)    specifies about which axes the rotations occur
;    PHI    dp       1st rotation (radians)
;    THETA  dp       2nd rotation (   "   )
;    PSI    dp       3rd rotation (   "   )
;
;  Returned:
;    RMAT   dp(3,3)  rotation matrix
;
;  A rotation is positive when the reference frame rotates
;  anticlockwise as seen looking towards the origin from the
;  positive region of the specified axis.
;
;  The characters of ORDER define which axes the three successive
;  rotations are about.  A typical value is 'ZXZ', indicating that
;  RMAT is to become the direction cosine matrix corresponding to
;  rotations of the reference frame through PHI radians about the
;  old Z-axis, followed by THETA radians about the resulting X-axis,
;  then PSI radians about the resulting Z-axis.
;
;  The axis names can be any of the following, in any order or
;  combination:  X, Y, Z, uppercase or lowercase, 1, 2, 3.  Normal
;  axis labelling/numbering conventions apply;  the xyz (=123)
;  triad is right-handed.  Thus, the 'ZXZ' example given above
;  could be written 'zxz' or '313' (or even 'ZxZ' or '3xZ').  ORDER
;  is terminated by length or by the first unrecognised character.
;
;  Fewer than three rotations are acceptable, in which case the later
;  angle arguments are ignored.  Zero rotations produces a unit RMAT.
;
;  P.T.Wallace   Starlink   November 1988
;-
pro slaDEULER, ORDER, PHI, THETA, PSI, RMAT

;  Initialise result matrix
         result    = dblarr(3,3)
         diag = indgen(3)
         result( diag,diag ) = 1d0

;  Establish length of axis string
         L = STRLEN(ORDER)

;  Look at each character of axis string until finished
         for n=0,2 do begin
              if (n lt L) then begin

;        Initialise rotation matrix for the current rotation
                   rotn                = dblarr(3,3)
                   rotn( diag,diag )   = 1d0

;        Pick up the appropriate Euler angle and take sine & cosine
                   case n of
                        0    : angle = phi
                        1    : angle = theta
                        else : angle = psi
                   endcase
                   s = sin(angle)
                   c = cos(angle)

;        Identify the axis
                   axis = strupcase( strmid(order,n,1) )
                   case 1 of
                        (axis eq 'X') or $
                        (axis eq '1')       : begin
;                                             Matrix for x-rotation
                                                rotn(1,1) = c
                                                rotn(1,2) = s
                                                rotn(2,1) = -s
                                                rotn(2,2) = c
                                              end
                        (axis eq 'Y') or $
                        (axis eq '2')       : begin
;                                             Matrix for y-rotation
                                                rotn(0,0) = c
                                                rotn(0,2) = -s
                                                rotn(2,0) = s
                                                rotn(2,2) = c
                                              end
                        (axis eq 'Z') or $
                        (axis eq '3')       : begin
;                                             Matrix for z-rotation
                                                rotn(0,0) = c
                                                rotn(0,1) = s
                                                rotn(1,0) = -s
                                                rotn(1,1) = c
                                              end
                                      else  : L = 0
;                                             Unrecognised character
;                                             - fake end of string
                   endcase


;        Apply the current rotation (matrix ROTN x matrix RESULT)

                   result    = rotn # result

              endif

         endfor

;  Copy the result
         rmat = result

end
