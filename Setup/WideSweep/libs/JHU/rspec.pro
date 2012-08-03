;-------------------------------------------------------------
;+
; NAME:
;       RSPEC
; PURPOSE:
;       Compute an ensemble averaged frequency spectrum of real data.
; CATEGORY:
; CALLING SEQUENCE:
;       sxx = rspec(x,n,sr,[freq])
; INPUTS:
;       x = input signal.                               in
;         If x has too few points, -1 is returned.
;       n = number of points to use in each transform   in
;         May be arbitrary.
;       sr = sample rate in Hz (Def=1 Hz)               in
;         Needed to get actual units.
; KEYWORD PARAMETERS:
;       Keywords:
;         OVERLAP=novr  number of points to overlap spectra (Def=0).
;         ZEROPAD=zlen  length to zero pad out to (def=no 0 pad).
;         N_ENSEMBLE=n  returned # spectra ensemble averaged.
;         /ACCUMUALTE means accumulate the spectra, don't average.
;         /NOTES lists some additional comments.
; OUTPUTS:
;       sxx = spectral density in units of x^2/Hz.      out
;         First value is DC, last is Nyquist.
;       freq = optionally output frequency array.       out
; COMMON BLOCKS:
;       rspec_com
; NOTES:
;       Notes: Restricted to one dimensional data only.
;         Reference: 
; MODIFICATION HISTORY:
;       B. L. Gotwols Oct. 11, 1990.
;       R. E. Sterner  7 Aug, 1991 --- return only 1-side (symetric)
;       R. D. Chapman  2 Dec, 1992 --- fixed common blk reference to hannratio
;       R. E. Sterner  1 Mar, 1993 --- tested for ntimes eq 0 sooner.
;       R. Sterner, 19 May, 1993 --- forced correct data types.
;       Rewrote from xspec.pro to get overlap.
;       R. Sterner, 23 Nov, 1993 --- Added /ACCUMULATE keyword
;       R. Sterner, 1994 Nov 10 --- Added ZEROPAD keyword.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	function rspec, x, n0, sr0, freq, overlap=novr0,  n_ensemble=n_en, $
	    help=hlp, notes=notes, accumulate=acc, zeropad=zlen
 
	common rspec_com, nlast,srlast,w,freq0,hannratio,zlast,zero,slen
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  if not keyword_set(notes) then begin
	  print,' Compute an ensemble averaged frequency spectrum of real data.'
	  print,' sxx = rspec(x,n,sr,[freq])'
	  print,'   x = input signal.                               in'
	  print,'     If x has too few points, -1 is returned.'
	  print,'   n = number of points to use in each transform   in'
	  print,'     May be arbitrary.'
	  print,'   sr = sample rate in Hz (Def=1 Hz)               in'
	  print,'     Needed to get actual units.'
	  print,'   sxx = spectral density in units of x^2/Hz.      out'
	  print,'     First value is DC, last is Nyquist.'
          print,'   freq = optionally output frequency array.       out'
	  print,' Keywords:'
	  print,'   OVERLAP=novr  number of points to overlap spectra (Def=0).'
	  print,'   ZEROPAD=zlen  length to zero pad out to (def=no 0 pad).'
	  print,'   N_ENSEMBLE=n  returned # spectra ensemble averaged.'
	  print,"   /ACCUMUALTE means accumulate the spectra, don't average."
	  print,'   /NOTES lists some additional comments.'
	  print,' Notes: Restricted to one dimensional data only.'
	  print,'   Reference: '
	  return,-1
	  endif
	endif
 
	if keyword_set(notes) then begin
          print,'   Procedure: s = rspec(x,n,sr)
          print,'     where the data to be analyzed is in x.
          print,'   Note that the returned spectrum is two sided in frequency.
          print,'   It is a spectral density similar to what one would
          print,'   measure with an analog instrument (ie. a continuum
          print,'   measurement.) except the spectral density returned would
          print,'   have to be doubled for direct comparison with most
          print,'   commercial spectrum analyzers.
	  print,'   A Hanning window has been applied to each transform, and a
	  print,'   multiplicative correction applied to compensate for the
	  print,"   window. Ignoring the window's effects, the mean sq of x can
	  print,'   be recovered by ms = (sr/n) * (sum[i = 1 to n - 1] Sxx(i))
	  print,'   The sr/n term converts from analog continuum spectral
	  print,'   density to total bandpassed mean square.  There may be
	  print,'   data left out of the ensemble if the number of elements
	  print,'   in eta is not an integral multiple of n. This is not
	  print,'   harmful.
	  print,'   NOTE: the spectra are approximately corrected for the
	  print,'   Hanning window with a constant 8/3 factor rather than
	  print,'   an empirically derived factor as in an older routine.
	  print,'   With the older routine, unresolved low frequency trends
	  print,'   gave a factor that is incorrect for the second and
	  print,'   higher harmonics.  Thus the constant factor seems a
	  print,'   better compromise, although now the fundamental may be
	  print,'   off and the mean square will no longer be exactly
	  print,'   recovered by integrating the spectrum.  The DC term is 
	  print,'   handled seperately in order to avoid corrupting the low 
	  print,'   frequency components.
	  return, -1
	endif
 
	;---------  Set default values  ---------------
	n = long(n0)					 ; Force long.
        if n_elements(novr0) eq 0 then novr0 = 0	 ; Def=0 overlap.
	novr = long(novr0)				 ; Force long.
	sr = float(sr0)					 ; Force float.
	if n_elements(sr) eq 0 then sr = 1.		 ; Def sample rate=1 Hz.
	if n_elements(zlen) eq 0 then zlen = 0		 ; No 0 pad.
 
        ;------  Update common if needed  ---------
        if n_elements(nlast) eq 0 then nlast = 0
        if n_elements(srlast) eq 0 then srlast = 0
        if n_elements(zlast) eq 0 then zlast = 0
        if (n ne nlast) or (sr ne srlast) or (zlen ne zlast) then begin
          nlast = n                     ; Remember spectrum length.
          srlast = sr                   ; Remember sample rate.
	  zlast = zlen			; Remember zero pad length.
	  ;-------  Hanning weighting array  ---------
          w=costap(n,0.)                ; Hanning weights
          hannratio = 8./3.             ; Hann window correction factor
          ;-------  Make frequency array  ------------
	  slen = n>zlen			; Spectra length.
          ny = sr/2.                    ; Nyquist freq = 1/2 sample rate.
          df = ny/(slen/2.)        ; Step size in freq: ny occurs at index n/2.
	  freq0 = findgen(1+(slen/2))*df  ; Array frequencies.
	  ;-------  Zero pad array  -----------
	  if zlen gt 0 then zero = fltarr(zlen)	; Zero pad array.
        endif
 
        ;------  Return frequency array only if requested  ------
        if n_params(0) ge 4 then freq = freq0
 
	;------  Set up storage  --------------
	sxx = fltarr(slen)			; spectra of x.
 
	;----------  Find some preliminary values  ------------
 	nl=long(n)			; We want this to be a long int.
	np = n_elements(x)		; Total points in x.
	nstep = n - novr		; Step novr less than # pts in spect.
	nt = np - novr			; Total # usable points.
	ntimes = nt/nstep		; Number of spectra to ensemble average
	n_en = ntimes			; Return # spectra ensemble averaged.
	if ntimes eq 0 then return,-1	; Return a -1 error flag
	nused = ntimes*nstep + novr	; Number of points we actually use
	xmean = mean(x(0:nused-1))	; Overall mean of the data we use
 
	;-----  Ensemble average the data  ----------------
	for i= 0L,ntimes-1 do begin
	  lo = i*nstep			; Data start index.
	  hi = lo + n - 1		; Data end index.
	  xx = x(lo:hi)			; Isolate the data to transform
	  if zlen eq 0 then begin
	    xx = (xx-mean(xx))*w	; subtract the mean and apply window
	    fxx = fft(xx,-1)		; take the fft
	  endif else begin
	    zero(0) = (xx-mean(xx))*w	; - the mean, apply window, 0 pad.
	    fxx = fft(zero,-1)		; take the fft
	  endelse
	  sxx = sxx + float(fxx*conj(fxx))  ; accumulate the spectra
	endfor
 
	if keyword_set(acc) then ntimes = 1L
 
	;-------  average spectral density taking ccount of IDL's 1/n factor
	;-------  for the forward transform, and correcting for the effect of
	;-------  the Hanning window.
	sxx = (sxx/ntimes)*(slen/sr)*hannratio
 
	;-------  Restore DC term  -------------
	sxx(0) = (slen*xmean^2)/sr
 
	return,sxx(0:slen/2)		; Return one side: DC to Nyquist.
 
	end
