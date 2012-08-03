;+
; NAME:
;        SCANPHI
;
; PURPOSE:
;        Finds the scan longitude or PHI corresponding the a response
;        function value, assuming that the scan latitude = 0 by inverting
;        the collimator response function.
;
; CATEGORY:
;        HEAO.
;
; CALLING SEQUENCE:
;
;        Result = SCANPHI( Trns )
;
; INPUTS:
;        Trns:     The peak value of the response function.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        DEGREES:  Return the scan longitude in DEGREES, (default=RADIANS).
;
; OUTPUTS:
;        Returns the scan longitude in RADIANS unless the DEGREES keyword
;        is set, corresponding to the peak of the Response Function
;        at scan latitude = 0.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, June 1994.
;
;-
function SCANPHI, Trns, DEGREES=Degrees

         COMMON CLLMTR, A,B,C,D,E,F,G,H,WT,WP,TF,PF
         if N_ELEMENTS( WT ) eq 0 then COLLINIT

         Coeff = [E(0), F(0), G(0), H(0)]

         phis  = CUBIC( Trns, Coeff )
         phi   = phis(*,0)

         if keyword_set( DEGREES ) then phi = phi*!radeg

         return, phi

end
