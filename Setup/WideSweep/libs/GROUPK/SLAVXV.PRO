;+
;*  - - - - - - -
;*   s l a V x v
;*  - - - - - - -
;*
;*  Vector product of two 3-vectors.
;*
;*  (single precision)
;*
;*  Given:
;*      va      float(3)     first vector
;*      vb      float(3)     second vector
;*
;*  Returned:
;*      vc      float(3)     vector result
;*
;*  P.T.Wallace   Starlink   31 October 1993
;-
pro slaVxv, va, vb, vc

;* Form the vector product va cross vb */
   n     = N_ELEMENTS( va )/3
   vw    = fltarr(3,n)
   vw(0,*) = va(1,*) * vb(2,*) - va(2,*) * vb(1,*);
   vw(1,*) = va(2,*) * vb(0,*) - va(0,*) * vb(2,*);
   vw(2,*) = va(0,*) * vb(1,*) - va(1,*) * vb(0,*);

;* Return the result */
   vc    = float( vw )

end
