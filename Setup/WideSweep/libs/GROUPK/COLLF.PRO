
;+
; NAME:
;        COLLF
;
; PURPOSE:
;        Function to return the HEAO A-1 collimator response function,
;        that is, transmission or efficiency, for a given detector module.
;
; CATEGORY:
;        Collimator.
;
; CALLING SEQUENCE:
;        Result = COLLF( Module,Ras,Des,Ray,Dey,Raz,Dez [,Theta,Phi])
;
; INPUTS:
;       Module:    Module number, in range 1-7, [integer].
;
;      Ras,Des:    The RA, DEC of the source in RADIANS, [float].
;
;      Ray,Dey:    The RA, DEC of the +Y axis in RADIANS, [float] or [float(nbin)].
;
;      Raz,Dez:    The RA, DEC of +Z axis in RADIANS, [float] or [float(nbin)].
;
; OUTPUTS:
;        This function returns the collimator response function (transmission)
;        for the given direction(s) specified by the aspect information,
;        [float] or [float(nbin)].
;
; OPTIONAL OUTPUTS:
;    Theta,Phi:    The collimator position angles defined in COLLMATR
;             in RADIANS, [float] or [float(nbin)].
;
; MODIFICATION HISTORY:
;        Written by:    Daryl J. Yentis, Naval Research Laboratory, SSD 1980.
;        12-NOV-1992    K.H. Fairfield, change to IMPLICIT NONE; use
;                       Fortran 77 block structure.
;        22-JUN-1994    H.C. Wen, converted into an IDL routine, vectorized
;                       routine to accept vector inputs.
;-
function COLLF, Module,Ras,Des,Ray,Dey,Raz,Dez,Theta,Phi

      PI = 3.1415926536 & TWOPI = 6.2831853072
      offset = 5.8177641733E-3

      M = abs(Module)
      if (Module GT 0) then begin
         RY = Ray
         DY = Dey
         if (M NE 7) then begin
            RY = RY+PI MOD TWOPI
            DY =-DY
         endif
         EULER2 ,Raz,Dez,RY,DY, /SETSYB
      endif

      EULER2, Ras,Des,Slong,Slat,7

      indices = WHERE( Slong GT PI, n_gt )
      if n_gt gt 0 then Slong(indices) = Slong(indices)-TWOPI
      Slong = Slong*COS(Slat)

      CASE 1 OF
        (M GE 1) and (M LE 4) :  N = 1   ; Module 1-4
        (M EQ 5) : BEGIN   ; Module 5 (OFFSET -1/3 degree toward sun)
                     N = 3
                     Slong = Slong - offset
                   END
        (M EQ 6) : BEGIN   ; Module 6 (OFFSET 1/3 degree away from sun)
                     N = 3
                     Slong = Slong + offset
                   END
        (M EQ 7) : N = 2   ; Module 7
             ELSE:message,'Invalid module number.'
      ENDCASE

      phi   = Slong
      theta = Slat
      return, COLLMATR(N,Slat,Slong)

end
