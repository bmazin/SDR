;+
; NAME:
;        OVERLAP
;
; PURPOSE:
;        This function determines the fraction of transmission function for
;        each source that is overlapping with the sum of the transmission
;        functions from all other sources.
;
; CATEGORY:
;        HEAO A-1.
;
; CALLING SEQUENCE:
;
;        Result = OVERLAP( Trns )
;
; INPUTS:
;        Trns:     A 2-d array holding the transmission values for each
;                  bin of the scan and for each source, [fltarr(nsrc,nbin)].
;
; OUTPUTS:
;        The function returns a fltarr(nsrc) array, giving the overlap fraction
;        for each source.
;
; PROCEDURE:
;        This function is used by the FIDUCIAL routine.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, February, 1995.
;-
function OVERLAP, Trns

         sz   = SIZE(Trns)
         nsrc = sz(1)
         nbin = sz(2)

         if nsrc eq 1 then return, [0.0]

         over = fltarr(nsrc)
         for i=0,nsrc-1 do begin
              here      = WHERE( Trns(i,*) gt 0, nbase )
              if nbase eq 0 then over(i) = -1 $
              else begin
                   here      = WHERE( indgen(nsrc) ne i )
                   trn_other = REFORM(TOTAL( Trns(here,*), 1 ))
                   trn_mix   = REFORM(Trns(i,*)) * trn_other
                   here      = WHERE( trn_mix ne 0, nmix )
                   over(i)   = float(nmix)/nbase
              endelse
         endfor

         return,over
end
