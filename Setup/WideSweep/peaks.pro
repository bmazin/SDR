;+
; NAME:
;      PEAKS
;
;
; PURPOSE:
;      Find the peaks in a vector (spectrum) which lie
;      NSIG above the standard deviation of all peaks in
;      the spectrum
;
; CALLING SEQUENCE:
;      result = peaks(y, nsig [,npk])
;
;
; INPUTS:
;      Y - Vector (usually a spectrum) in which you want to 
;          locate peaks.
;   NSIG - Number of sigma above the standard deviation of 
;          all peaks to search.
;
; OUTPUTS:
;
; RESULT - Vector holding the indecies of the peaks in Y
;
;
; OPTIONAL OUTPUTS:
;
;    NPK - The number of peaks located
;
; NOTES:
;
;    NSIG is NOT the number of sigma above the noise in the spectrum. 
;    It's instead a measure of the significance of a peak. First, all
;    peaks are located. Then the standard deviation of the peaks is 
;    calculated using ROBUST_SIGMA (see Goddard routines online). Then
;    peaks which are NSIG above the sigma of all peaks are selected.
; 
; EXAMPLE:
;
; IDL> y = randomn(seed,2000)
; IDL> pk = peaks(y,2)
; IDL> plot,y
; IDL> oplot,pk,y[pk],ps=2
;
; MODIFICATION HISTORY:
;
;-


function peaks,y,nsig,dum,level=level,count=npk
on_error,2
d0 = y - shift(y,1)
d1 = y - shift(y,-1)
pk = where(d0 gt 0 and d1 gt 0,npk)
if keyword_set(level) then begin
    bigind = where(y[pk] gt level, npk)
    return,pk[bigind]
endif

if n_elements(nsig) gt 0 then begin
    yp = y[pk]
    mn = robust_mean(yp,4)
    sig = robust_sigma(yp)
    bigind = where(yp gt mn + nsig*sig, npk)
    if npk gt 0 then big = pk[bigind] else big = -1
endif else big = pk

return,big
end