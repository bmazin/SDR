;+
; NAME:
;        COLLINIT
;
; PURPOSE:
;
;     To convert this into IDL code, the COMMON CLLMTR is needed to store
;     these coefficients as static variables.
;
;                       H.C. Wen, 22-JUN-1994
;
;     NRLDIR:COLLMAT.INC
;     ==================
;
;     Include file which declares the coefficient arrays, A,B,C,D,E,F,G,H,
;     and WT,WP, TF, and PF, used in the function COLLMATR to calculate
;     the collimator transmission function.  Comments below from the
;     original NRL code.  The orignal was a SUBROUTINE with DATA initiali-
;     zation statements for the arrays in COMMON /CLLMTR/.  This INCLUDE
;     file obviates the need for a COMMON, which has been removed.
;
;                       K.H. Fairfield, 12-NOV-1992
;
; Original Comments:
;
;     06/29/77 KINZER-MEEKINS
;     03/29/78 JALAL SAMIMI----MODIFIED USING CRAB OBSERVATIONS.
;     08/29/78 SNYDER
;     10/25/78 MEEKINS
;
;     For more information than is contained herein see the paper,
;     Kinzer, HEAO Collimators Monte-Carlo Simulation.  This routine (sic)
;     is used to both act as a single repository of collimator data and
;     to supply this data to the user if desired.  Note that this routine
;     should be called before any data in the COMMON BLOCK, CLLMTR, is
;     used.  The collimator number, I, identifies the collimator:
;     I=1(4x1), =2(2x8), =3(1/2x1), =4(1/2x1), =5(SUM 4x1s). Values given
;     are for one keV, values for energies up to 20 keV are identical.
;     THETA is the angle to coll zenith in the plane of the coll zenith
;     and the s/c spin axis.
;
;     PHI is the angle to collimator zenith in the plane orthogonal to
;     the spin axis.  Offsets in both THETA and PHI have been included
;     (TF and PF) in order that intentional or unintentional
;     misalignments with the s/c look direction (Y-axis) be treated.
;     THETA is positive when toward the spin axis, PHI is positive in
;     direction of spin. The collimator response has been fit to cubic
;     polynomials.  An algorithm for calculating the collimator response,
;     CR, for a look angle (TH,PH, measured wrt the Y-axis) might be as
;     follows (T is equiv. to THETA and P is equiv. to PHI):
;
;         T=ABS(THETA-TF)
;         P=ABS(PHI-PF)
;         CRT=A+T*(B+T*(C+T*D))
;         CRP=E+P*(F+P*(G+P*H))
;         CR=CRT*CRP
;         IF((P.GT.WP).OR.(T.GT.WT)) CR=0.
;
;     Note that THETA and PHI must be in radians and that WT,TF,WP, and
;     PF are in radians.
;
; CATEGORY:
;        Collimator.
;
; CALLING SEQUENCE:
;        COLLINIT
;
; INPUTS:     None.
;
; OUTPUTS:
;        This routine initializes the CLLMTR common so that the routines,
;        COLLMATR and COLLF may be subsequently used.
;
; COMMON BLOCKS:
;        CLLMTR:   Coefficient arrays which hold information needed to
;             calculate the collimator transmission function.
;
; RESTRICTIONS:
;        You must call this routine before using COLLMATR or COLLF.  Currently,
;        COLLMATR automatically calls COLLINIT if the WT variable has not
;        been initialized.
;
; MODIFICATION HISTORY:
;        Written by:    See Above.
;        22-JUN-1994    H.C. Wen, converted include file into an IDL routine.
;        15-AUG-1995    Comment bugfix: removed extraneous ;+ and ;-.
;-
pro COLLINIT

      COMMON CLLMTR, A,B,C,D,E,F,G,H,WT,WP,TF,PF
;     REAL*4 A(5),B(5),C(5),D(5),E(5),F(5),G(5),H(5)
;     REAL*4 WT(5),WP(5), TF(5),PF(5)

;
;     REVISION 08/29/78
;
      A=[ 1.0,1.,1.,1.,1.]
      B=[-17.1629,-36.3026,-129.133,-129.133,-17.1629]
      C=[-45.3724,271.652,3088.825,3088.825,-45.3724]
      D=[1248.906,-1352.28,-129175.22,-129175.22,1248.906]
      E=[1.0,1.,1.,1.,1.]
      F=[-37.8444,-14.8436,-63.1859,-63.1859,-37.8444]
      G=[-2980.20,69.7268,-56.0375,-56.0375,-2980.20]
      H=[112897.9532,-105.493,27160.33,27160.33,112897.9532]
;
;     REVISION 10/25/78
;
      WP=[0.0183390,0.139395,0.0180749,0.0180749,0.0183390]
      WT=[0.0709385,0.0351891,0.00894117,0.00894117,0.0709385]

      TF=[0.0000,0.0000,0.00582,-0.00582,0.0000]
      PF=[0.0000,0.0000,0.0000,0.0000,0.0000]

;
;     REVISION 10/01/94
;
      B(0) = -19.2231
      C(0) =  51.3240
      D(0) =  287.756

end
