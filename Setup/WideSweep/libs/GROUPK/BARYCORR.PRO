;+
;        FUNCTIONAL DESCRIPTION:
;
;        Function calculates the satellite's position in barycentric
;        coordinates, then calculates a time correction based no the
;        projection of the satellite's position vector into the source
;        direction (from the Earth).  Thus the time is corrected to a
;        fixed point on the Earth-source line, such that the line joining
;        that point to the barycenter is pependicular to the Earth-source
;        line.
;
; INPUT PARAMETERS:
;
;        SRCVEC  floating-point array giving the unit 3-vector to from the
;             Earth to the source object, in celestial coordinates.
;
;        SATVEC  floating-point array giving the satellite's position
;             3-vector relative to Earth-center, in kilometers.
;
;        JTIME     double-precision modified Julian date for which the
;             correction is to be calculated (JD1950) in days.
;
; OUTPUT PARAMETERS:
;
;        None.
;
; RETURNS:
;
;        BARY_CORR = (double-precision) delta-time (seconds) which, when
;                 added to JTIME, gives the time at the correction point
;                 discussed above.
;
; NOTES:
;
;        This code based on SUBROUTINE BARYTIME written by Lynn Cominsky.
;
; AUTHOR/DATE:          K.H. Fairfield,           04-DEC-1992
;
;-
function BARYCORR, Srcvec, Satvec, Jtime

         aunit     = 1.495978706d8     ; one au in km.
         cvel      = 2.99792458d5      ; vel. of light, km/s
         deqx      = 1950.d0           ; 1950 epoch

         dsrc      = dblarr(3)
         dsrc(0)   = double (srcvec(0))
         dsrc(1)   = double (srcvec(1))
         dsrc(2)   = double (srcvec(2))
         sladvn, dsrc, dsrc, dn

         slaevp, jtime, deqx, dvel,dpos, dvh,dvp

         dsat      = dpos*aunit  + double( satvec )

         bary_corr = sladvdv(dsat, dsrc) / cvel

         return, bary_corr
end
