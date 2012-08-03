function slaDvdv, va, vb
;+
;   - - - - - - - -
;    s l a D v d v
;   - - - - - - - -
;
;  Scalar product of two 3-vectors  (double precision)
;
;  Given:
;      VA      dp(3)     first vector
;      VB      dp(3)     second vector
;
;  The result is the scalar product VA.VB (double precision)
;
;  P.T.Wallace   Starlink   November 1984
;-
   return, TOTAL( va * vb, 1 )

end
