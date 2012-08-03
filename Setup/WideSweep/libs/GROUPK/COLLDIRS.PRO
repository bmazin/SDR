;+
; NAME:
;        COLLDIRS
;
; PURPOSE:
;        This procedure determines the viewing direction(s) of one
;        of the HEAO A-1 collimators.
;
; CATEGORY:
;        HEAO A-1 Geometry.
;
; CALLING SEQUENCE:
;        COLLDIRS, Module,RAY,DEY,RAZ,DEZ [,RAc,DECC]
;
; INPUTS:
;       Module:    Module number of the collimator (1-7), [integer].
;      RAY,DEC:    The RA,DEC  of the satellite's Y-axis in RADIANS, [float(nbin)].
;
; OPTIONAL OUTPUTS:
;     RAc,DECc:    The RA,DEC of the collimator viewing direction, [float(nbin)].
;
; OPTIONAL KEYWORD OUTPUTS:
;           RC:    The unit direction vector in spherical coordinates of the
;             collimator viewing direction, [float(3,nbin)].
;
; RESTRICTIONS:
;        NOTE: you can also call this routine with scalar input arguments.
;
; EXAMPLE:
;        let's choose a RA,DEC near the poles and determine the
;        viewing direction for collimator 3.
;
;        RA = 75.5*!dtor
;        DEC= 89.8*!dtor
;
;        COLLDIRS, 3, RA, DEC, RA_M3, DEC_M3, RC=Vec_M3
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, June 1994.
;-
pro COLLDIRS, Module,RAY,DEY,RAZ,DEZ, RAc,DECc,RC=Rc

         M = Module
         CASE 1 OF
             (M ge 1) and $
             (M le 4):BEGIN
                        RAc = RAY + !dpi  ;-Y axis
                        DECc= -DEY
                        slaCs2c, RAc, DECc, Rc
                        return
                      END
             (M eq 5):off_ang =  (1./3.)*!dtor
             (M eq 6):off_ang = -(1./3.)*!dtor
             (M eq 7):BEGIN
                        RAc = RAY
                        DECc= DEY
                        slaCs2c, RAc, DECc, Rc
                        return
                      END
                 ELSE:message,'Invalid module number.'
         ENDCASE

;   Modules 5 and 6 have their viewing directions offset from the
;   -Y axis by +/- 1/3 degree.  3 constraints provides 3 equations:
;                    1) R # -Y    = cos( off_ang )
;                    2) R # Z     = sin( off_ang )
;                    3) R # (-Y x Z) = 0      (Axis in same plane)
;   which provide the coeff's for a 3 x 3 matrix.  Inverting this matrix times
;   the vector formed from the scalars of the r.h.s. of these equations
;   determines the cartesian coordinates of the module 5/6 scanning directions.
;   To vectorize this routine we had to invert this matrix "by hand" instead
;   of utilizing IDL's matrix operators.

;   Get the -Y axis vector(s):
         RAneg = RAY + !dpi
         DECneg= -DEY
         slaCs2c, RAneg, DECneg, negYs
         cosO      = cos( off_ang )      ;angle from -Y axis lying
         sinO      = sin( off_ang )      ;in the Y-Z plane

;   the Z axis and X-axis vector(s):
         slaCs2c, RAZ, DEZ, Zs
         slaVxv,  Zs, negYs, Xs

         detA = Xs(0,*) * (negYs(1,*)*Zs(2,*) - negYs(2,*)*Zs(1,*))+$
                Xs(1,*) * (negYs(2,*)*Zs(0,*) - negYs(0,*)*Zs(2,*))+$
                Xs(2,*) * (negYs(0,*)*Zs(1,*) - negYs(1,*)*Zs(0,*))
         i_zero = WHERE( detA eq 0, nzero )
         if nzero gt 0 then begin
               print,'ERROR: Determinant of matrix(es) = 0!'
               print,i_zero
               return
         endif

         A00  = Xs(2,*) *Zs(1,*)    - Xs(1,*) *Zs(2,*)    ;row 0
         A01  = Xs(1,*) *negYs(2,*) - Xs(2,*) *negYs(1,*)
;        A02  = negYs(1,*)*Zs(2,*)  - negYs(2,*)*Zs(1,*)

         A10  = Xs(0,*) *Zs(2,*)    - Xs(2,*) *Zs(0,*)    ;row 1
         A11  = Xs(2,*) *negYs(0,*) - Xs(0,*) *negYs(2,*)
;        A12  = negYs(2,*)*Zs(0,*)  - negYs(0,*)*Zs(2,*)

         A20  = Xs(1,*) *Zs(0,*)    - Xs(0,*) *Zs(1,*)    ;row 2
         A21  = Xs(0,*) *negYs(1,*) - Xs(1,*) *negYs(0,*)
;        A22  = negYs(0,*)*Zs(1,*)  - negYs(1,*)*Zs(0,*)

         A00  = A00/detA
         A01  = A01/detA
;        A02  = A02/detA
         A10  = A10/detA
         A11  = A11/detA
;        A12  = A12/detA
         A20  = A20/detA
         A21  = A21/detA
;        A22  = A22/detA

         n       = N_ELEMENTS( RAY )
         Rc      = fltarr(3,n)
         Rc(0,*) = A00*cosO + A01*sinO
         Rc(1,*) = A10*cosO + A11*sinO
         Rc(2,*) = A20*cosO + A21*sinO

         slaCc2s, Rc, RAc,DECc

end
