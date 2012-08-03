;+
; NAME:
;        SCANTHT
;
; PURPOSE:
;        Finds the scan latitude or THETA corresponding the a response
;        function value, assuming that the scan longitude = 0 by inverting
;        the collimator response function.
;
; CATEGORY:
;        HEAO.
;
; CALLING SEQUENCE:
;
;        Result = SCANTHT( Trns )
;
; INPUTS:
;        Trns:     The peak value of the response function.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        DEGREES:  Return the scan latitude in DEGREES, (default=RADIANS).
;
; OUTPUTS:
;        Returns the scan latitude in RADIANS unless the DEGREES keyword
;        is set, corresponding to the peak of the Response Function
;        at scan longitude = 0.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, June 1994.
;
;-
function SCANTHT, Trns, DEGREES=Degrees

         COMMON CLLMTR, A,B,C,D,E,F,G,H,WT,WP,TF,PF
         if N_ELEMENTS( WT ) eq 0 then COLLINIT

         Coeff = [A(0), B(0), C(0), D(0)]

         thts  = CUBIC( Trns, Coeff )
         tht   = thts(*,0)

         if keyword_set( DEGREES ) then tht = tht*!radeg

         return, tht

end
