;+
; NAME:
;        MTOEA
;
; PURPOSE:
;        Computes the euler angles to transform body axes to space axes,
;        given the transformation matrix from the body axes to the space axes.
;
; CATEGORY:
;        Analytic Geometry.
;
; CALLING SEQUENCE:
;        MTOEA, Matrix,A,B,C
;
;
; INPUTS:
;       Matrix:    The 3x3 rotation matrix, [float(9)].
;
; OUTPUTS:
;            A:    First euler angle in radians, -PI < A < PI, [float].
;
;            B:    Second euler angel in radians, 0 < B < PI, [float].
;
;            C:    Third euler angle in radians, -PI < C < PI, [float].
;
; RESTRICTIONS:
;        NOTE: There is a replacement routine in this library,
;         called dmtoea().  Besides being a double-precision
;         version, it uses a more robust transformation algorithm
;         --johnf, 7 March 1989
;
; MODIFICATION HISTORY:
;        Written by:    John F., 1/30/75
;        06-JUN-94:     Adapted into an IDL routine, H.C. Wen.
;        15-AUG-1995    Comment bugfix: removed extraneous ;+ and ;-.
;-
pro MTOEA, R,A,B,C

         PI=3.141592653589793
         PI2=6.283185307179586

         S3= R(2)
         S6=-R(5)
         A = atan(S3,S6)
         S9= R(8)
         B = atan(SQRT(S3*S3+S6*S6),S9)
         C = atan(R(6),R(7))
         IF (ABS(S9) LT 0.9999) THEN RETURN
;
; Near pole or antipole
;
         S9= SIGN(1.00,S9)
         A = atan(R(3)-S9*R(1),R(0)+S9*R(4))-S9*C
         A = A MOD PI2
         IF (ABS(A) GT PI) THEN A=A-SIGN(PI2,A)

end
