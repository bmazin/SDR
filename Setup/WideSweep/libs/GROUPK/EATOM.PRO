;+
; NAME:
;        EATOM
;
; PURPOSE:
;        Generate rotation matrix given 3 euler angles
;
; CATEGORY:
;        Analytic geometry.
;
; CALLING SEQUENCE:
;        EATOM, A, B, C, D
;
; INPUTS:
;            A:    First euler angle in radians, [float] or [float(nbin)].
;            B:    Second euler angle in radians, [float] or [float(nbin)].
;            C:    Third euler angle in radians, [float] or [float(nbin)].
;
;        THE EULER ROTATION IS DEFINED AS FOLLOWS:
;        1) ROTATE CCW BY ANGLE A ABOUT Z-AXIS GIVING X', Y', Z'-AXES
;        2) ROTATE CCW BY ANGLE B ABOUT X'-AXIS GIVING X", Y", Z"-AXES
;        3) ROTATE CCW BY ANGLE C ABOUT Z"-AXIS
;
;
; OUTPUTS:
;            D:    Returned 3x3 rotation matrix as a 1-D array, [float(3,3)]
;                  or [float(3,3,nbin)].
;
;        REFERENCE:
;        CLASSICAL MECHANICS, H. GOLDSTEIN, ADDISON WESLEY, 1950, P 107 FF
;         The three euler angles define a coordinate system rotation
;         from the original axes to a new set of axes.  The rotation
;         matrix returned by EATOM rotates the coordinates of a vector
;         in the original axes to the coordinates in the new set.
;          x' = Dx
;
;
; MODIFICATION HISTORY:
;        Written by:    K.H. Fairfield, 1993.
;        06-JUN-94:     Modified into an IDL routine, H.C. Wen.
;        22-JUN-94:     Vectorized routine to accept vector inputs
;-
pro EATOM, A,B,C,D

         sinA = sin(A)
         cosA = cos(A)

         sinB = sin(B)
         cosB = cos(B)

         sinC = sin(C)
         cosC = cos(C)

         exp1 = sinA*cosB
         exp2 = cosA*cosB

         n    = N_ELEMENTS(A)
         D    = fltarr(3,3,n)

         D(0,0,*) = +cosA*cosC-exp1*sinC
         D(1,0,*) = -cosA*sinC-exp1*cosC
         D(2,0,*) = +sinA*sinB

         D(0,1,*) = +sinA*cosC+exp2*sinC
         D(1,1,*) = -sinA*sinC+exp2*cosC
         D(2,1,*) = -cosA*sinB

         D(0,2,*) = sinB*sinC
         D(1,2,*) = sinB*cosC
         D(2,2,*) = cosB

         D = REFORM(D)  ;trim to 3 x 3 matrix if n=1
end
