;+
; NAME:
;        GET_PEAK
;
; PURPOSE:
;        Finds the bin(s) where the transmission curves are a maximum.
;
; CATEGORY:
;        Curve fitting.
;
; CALLING SEQUENCE:
;        Result = GET_PEAK( Trns )
;
; INPUTS:
;         Trns:    A nsrc x nbin array of transmission functions, [float( nsrc, nbin )].
;
; OUTPUTS:
;        This functions returns the bin numbers where the transmission
;        curves are a maximum, [integer(nsrc)].
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, May, 1994.
;        17-MAY-1994:   Restricted the functionality of this routine to ONLY
;                       returning the bins; moved other characteristics, like
;                       the fitted background @ peak to the routine(s) which
;                       calculate these values.
;-
function GET_PEAK, Trns

         ON_ERROR,2              ; Return to caller if an error occurs

         NP = N_PARAMS()
         if (NP ne 1) then $
            message, 'Must be called with 1 parameter: Trns'

;  Let's determine the length of these arrays and the number of sources

         STrns     = SIZE( Trns )
         nsrc      = STrns(1)

         bin_pk    = intarr( nsrc )
         Trnsinv   = TRANSPOSE( Trns )
         for i=0,nsrc-1 do begin
             trn_max = MAX( Trnsinv( *,i ), bin )
             bin_pk(i) = bin
         endfor

         return, bin_pk
end
