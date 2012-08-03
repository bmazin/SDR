function slaVdv, va, vb
;+
;*  - - - - - - -
;*   s l a V d v
;*  - - - - - - -
;*
;*  Scalar product of two 3-vectors.
;*
;*  (single precision)
;*
;*  Given:
;*      va      float[3]     first vector
;*      vb      float[3]     second vector
;*
;*  The result is the scalar product va.vb  (single precision).
;*
;*  P.T.Wallace   Starlink   15 July 1993
;-

   return, TOTAL( va * vb, 1 )

end
