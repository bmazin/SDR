;+
;     - - - - - - -
;      s l a D V N
;     - - - - - - -
;
;  Normalises a 3-vector also giving the modulus (double precision)
;
;  Given:
;     V       dp(3)      vector
;
;  Returned:
;     UV      dp(3)      unit vector in direction of V
;     VM      dp         modulus of V
;
;  If the modulus of V is zero, UV is set to zero as well
;
;  P.T.Wallace   Starlink   November 1984
;-
pro slaDVN, V, UV, VM

;   Modulus
         w1=TOTAL(v*v)
         w1=sqrt(w1)
         vm=w1

;   Normalise the vector
         if (w1 le 0d0) then w1=1d0
         uv   =v/w1

end
