
;+
; NAME:
;        COLLMATR
;
; PURPOSE:
;
;        For a given collimator (module) index, and given angle with
;        respect to the collimator axis, calculates the transmission
;        function.  See original comments below.
;
; CATEGORY:
;        Collimator.
;
; CALLING SEQUENCE:
;        Result = COLLMATR( I,TH,PH )
;
; INPUTS:
;       I:    An integer giving the collimator index, in the range 1-5.
;
;      TH:    A real value giving the angle THETA in RADIANS (see below).
;
;      PH:    A real value giving the angle PHI in RADIANS (see below).
;
;
; OUTPUTS:
;        This function returns the value(s) of the transmission function
;        for the provided angles relative to the collimator axis
;        in the range 0.0 to 1.0.
;
; COMMON BLOCKS:
;        CLLMTR:   Coefficient arrays which hold information needed to
;             calculate the collimator transmission function.
;
; MODIFICATION HISTORY:
;
;  NOTES:
;
;     The original comments refer to "ENTRY XXXX", while,
;     in fact, there were NO entry points.  Instead, there is a computed
;     GOTO which jumps (supposedly) to particular labels ("entry points").
;     However, the GOTO variable, IENT, was LOCAL and defined to be zero
;     on entry to this procedure, so ONLY the Collimator function was
;     returned.   The other functions in the package were unavailable.
;     See revision of 11/12/92 below.
;
;  AUTHOR/DATE:         Meekins,       25-JUL-1979
;
;  REVISIONS:
;
;   H.C. Wen,           22-JUN-1994:
;        Converted into an IDL routine, restored COMMON CLLMTR
;        15-AUG-1995    Comment bugfix: removed extraneous ;+ and ;-.
;
;   K.H. Fairfield,     12-NOV-1992:
;       Changed to IMPLICIT NONE.  Removed COMMON /CLLMTR/ in favor of
;   INCLUDE file data initailization of coefficient arrays.  Edited
;   original comments.
;
;       Separated each "entry" into its own function, each includes the
;       coefficient-array data initialization file.  Makes the image
;       smaller after linking; makes the "entry" points available to
;       callers again.
;
;
;  ORIGINAL COMMENTS:
;  =================
;
;     INSTRUMENT, HEAO-A1, COLLIMATOR.  CODED FOR CDC3800.
;
;     This routine is used to find the following:
;
;       Collimator function (entry COLLMATR)
;
;       First Derivative of the collimator function wrt THETA (entry DCOLLDTH)
;
;       First Derivative of the collimator function wrt PHI (entry DCOLLDPH)
;
;       Integral of the collimator function over THETA, from
;          -Infinity to THETA (entry COLLITH)
;
;       Integral of the collimator function over PHI, from
;          -Infinity to PHI (entry COLLIPH)
;
;       Integral of the collimator function over THETA and PHI from
;          -Infinity to THETA and PHI (entry COLLINT)
;
;
;     All functions are evaluated at the angles THETA=TH and PHI=PH.
;     Note that TH and PH must be in radians and that all functions are
;     determined in radians. The collimator number, I, corresponds to
;     the collimators as follows:
;
;     I=1(4x1), =2(2x8), =3(1/2x1), =4(1/2x1), =5(ave of 4x1s)
;
;     TH is the angle wrt the s/c Y-axis in the X-Y plane,
;     PH is the angle wrt the s/c Y-axis in the Y-Z plane.
;
;     Y-axis is the nominal detector look direction.
;     X-axis is the roll axis.
;
;     THETA is positive when toward the X-axis,
;     PHI is positive in the direction of spin.
;
;     Note that the COMMON BLOCK, CLLMTR, is used.  The data in this
;     COMMON BLOCK are provided by the SUBROUTINE COLLMAT, which must
;     be called before using this routine.
;
;     WT (WP) and TF (PF) are the width and offset of the collimator in
;     the THETA (PHI) directions.
;
;        15-AUG-1995    Comment bugfix: removed extraneous ;+ and ;-.
;-
function COLLMATR, I,TH,PH

      COMMON CLLMTR, A,B,C,D,E,F,G,H,WT,WP,TF,PF
      if N_ELEMENTS( WT ) eq 0 then COLLINIT

      IN= I-1
      T = abs(TH-TF(IN))
      P = abs(PH-PF(IN))
      n = N_ELEMENTS( T ) > N_ELEMENTS( P )
;
;     CHECK RANGE, SET = 0 IF OUT OF RANGE
;     COLLMATR IS COLLIMATOR FUNCTION
;
      indices = WHERE( (T GE WT(IN)) or (P GE WP(IN)),nzero )
      if nzero eq n then return, REPLICATE( 0.,n )

      trnst   = A(IN)+T*(B(IN)+T*(C(IN)+T*D(IN)))
      trnsp   = E(IN)+P*(F(IN)+P*(G(IN)+P*H(IN)))

      trns = trnst*trnsp
      i_neg = WHERE( trns lt 0, nneg)
      if nneg gt 0 then trns(i_neg) = 0.0     ;Zero any negative values

      if nzero gt 0 then trns(indices) = 0.0  ;and any zero values

      return, trns
end


function DCOLLDTH, I, TH, PH

      COMMON CLLMTR, A,B,C,D,E,F,G,H,WT,WP,TF,PF
      if N_ELEMENTS( WT ) eq 0 then COLLINIT

;
;  DCOLLDTH is derivative of collimator function w.r.t. THETA
;  (perpendicular to roll plane)
;
      IN= I-1
      T = abs(TH-TF(IN))
      P = abs(PH-PF(IN))
      n = N_ELEMENTS( T )
;
;  Check range, set = 0 if out of range,
;
      indices = WHERE( (T GE WT(IN)) or (P GE WP(IN)),nzero )
      if nzero eq n then return, REPLICATE( 0.,n )

      trnsp  = E(IN)+P*(F(IN)+P*(G(IN)+P*H(IN)))
      dtrnst = B(IN)+T*(2.*C(IN)+T*3.*D(IN))

      ind = WHERE( TH eq TF(IN),n_eq )
      if n_eq gt 0 then dtrnst(ind) = 0.0

      ind = WHERE( TH lt TF(IN),n_lt )
      if n_lt gt 0 then dtrnst(ind) = -dtrnst(ind)

      deriv = trnsp*dtrnst
      derive(indices) = 0.0

      return, deriv

end



function DCOLLDPH, I, TH, PH

      COMMON CLLMTR, A,B,C,D,E,F,G,H,WT,WP,TF,PF
      if N_ELEMENTS( WT ) eq 0 then COLLINIT

;
;  DCOLLDPH is derivative of collimator function wrt PHI (in the roll plane).
;
      IN= I-1
      T = abs(TH-TF(IN))
      P = abs(PH-PF(IN))
      n = N_ELEMENTS( T )
;
;  Check range, set = 0 if out of range.
;
      indices = WHERE( (T GE WT(IN)) or (P GE WP(IN)),nzero )
      if nzero eq n then return, REPLICATE( 0.,n )

      trnst = A(IN)+T*(B(IN)+T*(C(IN)+T*D(IN)))
      dtrnsp = F(IN)+P*(2.*G(IN)+P*3.*H(IN))


      ind = WHERE( PH eq PF(IN),n_eq )
      if n_eq gt 0 then dtrnsp(ind) = 0.0

      ind = WHERE( PH lt PF(IN),n_lt )
      if n_lt gt 0 then dtrnsp(ind) = -dtrnsp(ind)

      deriv = trnst*dtrnsp
      derive(indices) = 0.0

      return, deriv
end



function COLLITH, I, TH, PH

      COMMON CLLMTR, A,B,C,D,E,F,G,H,WT,WP,TF,PF
      if N_ELEMENTS( WT ) eq 0 then COLLINIT

;
;  COLLITH is the collimator function integrated, from -infinity to TH
;  in the THETA direction.
;
      IN= I-1
      T = abs(TH-TF(IN))
      P = abs(PH-PF(IN))
      n = N_ELEMENTS( T )
;
;  Check range in PHI and check integration limit in THETA,
;  set = 0 if out of range.
;
      indices = WHERE( (P GE WP(IN)) or (TH LE (TF(IN)-WT(IN))),nzero )
      if nzero eq n then return, REPLICATE( 0.,n )

      trnsp = E(IN)+P*(F(IN)+P*(G(IN)+P*H(IN)))
      T1 = WT(IN)
;
;  Y1 is integral from -infinity to zero.
;
      Y1 = T1*(A(IN)+T1*(B(IN)/2.+T1*(C(IN)/3.+T1*D(IN)/4.)))
      ind = WHERE( (TH GT  (TF(IN)+WT(IN))), n_gt )
      if n_gt gt 0 then T(ind) = WT(IN)

;
;  Y2 is integral from zero to abs(THETA) initially.
;
      Y2 = T*(A(IN)+T*(B(IN)/2.+T*(C(IN)/3.+T*D(IN)/4.)))
      ind = WHERE( (TH LT TF(IN)), n_lt )
      if n_lt gt 0 then Y2(ind) = -Y2(ind)

      integ = (Y1+Y2)*trnsp
      integ( indices ) = 0.0

      return, integ
end



function COLLIPH

      COMMON CLLMTR, A,B,C,D,E,F,G,H,WT,WP,TF,PF
      if N_ELEMENTS( WT ) eq 0 then COLLINIT

;
;  COLLIPH is the collimator function integrated from -infinity to PH
;  in the PHI direction.
;
      IN= I-1
      T = abs(TH-TF(IN))
      P = abs(PH-PF(IN))
      n = N_ELEMENTS( T )
;
;  Check range in THETA and check integration limit in PHI, set = 0 if out
;  of range.
;
      indices = WHERE( (T GE WT(IN)) or (PH LE (PF(IN)-WP(IN)) ),nzero )
      if nzero eq n then return, REPLICATE( 0.,n )
      trnst = A(IN)+T*(B(IN)+T*(C(IN)+T*D(IN)))
      P1 = WP(IN)
;
;  Y1 is integral from -infinity to zero.
;
      Y1 = P1*(E(IN)+P1*(F(IN)/2.+P1*(G(IN)/3.+P1*H(IN)/4.)))
      ind = WHERE( (PH  GT  (PF(IN)+WP(IN))), n_gt)
      if n_gt gt 0 then P(ind) = WP(IN)

;
;  Y2 is integral from zero to abs(PHI) initially.
;
      Y2 = P*(E(IN)+P*(F(IN)/2.+P*(G(IN)/3.+P*H(IN)/4.)))
      ind = WHERE( (PH LT PF(IN)),n_lt)
      if n_lt gt 0 then Y2(ind) = -Y2(ind)

      integ = (Y1+Y2)*trnst
      integ( indices ) = 0.0

      return, integ

end


function COLLINT

      COMMON CLLMTR, A,B,C,D,E,F,G,H,WT,WP,TF,PF
      if N_ELEMENTS( WT ) eq 0 then COLLINIT
;
;  COLLINT is the collimator function integrated from -infinity to PH in PHI
;  direction and integrated from -infinity to TH in THETA direction.
;
      IN= I-1
      T = abs(TH-TF(IN))
      P = abs(PH-PF(IN))
      n = N_ELEMENTS( T )
;
;  Check integration limits, set = 0 if out of range.
;
      indices = WHERE( (TH LE TF(IN)-WT(IN)) or (PH LE PF(IN)-WP(IN)),nzero )
      if nzero eq n then return, REPLICATE( 0.,n )
      P1 = WP(IN)
;
;  Y1 is integral from -infinity to zero, PHI direction.
;
      Y1 = P1*(E(IN)+P1*(F(IN)/2.+P1*(G(IN)/3.+P1*H(IN)/4.)))
      ind = WHERE( (PH  GT  (PF(IN)+WP(IN))),n_gt)
      if n_gt gt 0 then P(ind) = WP(IN)

;
;  Y2 is integral from zero to abs(PHI) initially.
;
      Y2 = P*(E(IN)+P*(F(IN)/2.+P*(G(IN)/3.+P*H(IN)/4.)))
      ind = WHERE( (PH  LT  PF(IN)), n_lt)
      if n_lt gt 0 then Y2(ind) = -Y2(ind)
      T1 = WT(IN)
;
;  X1 is integral from -infinity to zero, THETA direction.
;
      X1 = T1*(A(IN)+T1*(B(IN)/2.+T1*(C(IN)/3.+T1*D(IN)/4.)))
      ind = WHERE( (TH  GT  (TF(IN)+WT(IN))), n_gt)
      if n_gt gt 0 then T(ind) = WT(IN)
;
;  X2 is integral from zero to abs(THETA) initially.
;
      X2 = T*(A(IN)+T*(B(IN)/2.+T*(C(IN)/3.+T*D(IN)/4.)))
      ind = WHERE( (TH  LT  TF(IN)), n_lt)
      if n_lt gt 0 then X2(ind) = -X2(ind)

      integ = (Y1+Y2)*(X1+X2)
      integ( indices ) = 0.0

      return, integ

end
