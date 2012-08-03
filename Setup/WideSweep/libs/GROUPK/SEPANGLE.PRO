;+
; NAME:
;        SEPANGLE
;
; PURPOSE:
;        This function calculates the separation angle in RADIANS from a source
;        direction as specified by their RA and DEC.
;
; CATEGORY:
;        Trigonometry.
;
; CALLING SEQUENCE:
;        Result = SEPANGLE( RAs, DECs, RAc, DECc )
;
; INPUTS:
;          RAs:    Right ascension of the source in radians, [float].
;
;         DECs:    Declination of the source in radians, [float].
;
;          RAc:    Right ascension of the second direction in radians.
;             This may be either a scalar, [float] or a vector, [float(nbin)].
;
;         DECc:    Declination of the second direction in radians.
;             This may be either a scalar, [float] or a vector, [float(nbin)].
;
; OUTPUTS:
;        The separation angle is returned in radians, [float] or [float(nbin)].
;
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, June 1994.
;        22-JUN-1994:   Vectorized routine to accept vector input arguments
;                       for the "collimator" aspects, RAc and DECc.
;-

function SEPANGLE, RAs, DECs, RAc, DECc

         n = N_ELEMENTS( RAc )

;  Get the unit vectors for the two directions.
         slaCS2C, RAs,DECs, Rs
         slaCS2C, RAc,DECc, Rc

;  Take their dot product

         dot = TOTAL( (Rs # REPLICATE(1.,n)) * Rc, 1 )

;  and return the separation angle between the two vectors
         return, acos( dot )

end
