;-------------------------------------------------------------
;+
; NAME:
;       CSPEC
; PURPOSE:
;       Compute ensemble averaged frequency spectrum of complex data.
; CATEGORY:
; CALLING SEQUENCE:
;       s = cspec(z,n,sr,[freq])
; INPUTS:
;       z = input signal: Z = X + iY.                   in
;         If z has too few points, -1 is returned.
;       n = number of points to use in each transform   in
;         May be arbitrary.
;       sr = sample rate in Hz                          in
;         Needed to get actual units
; KEYWORD PARAMETERS:
;       Keywords:
;         OVERLAP=novr  number of points to overlap spectra (Def=0).
;         ZEROPAD=zlen  length to zero pad out to (def=no 0 pad).
;         N_ENSEMBLE=n  returned # spectra ensemble averaged.
;         /NOTES lists some additional comments.
; OUTPUTS:
;       freq = optionally output frequency array.       out
;         If freq is requested then s is shifted for plots.
;       s = spectral density in units of z**2/Hz.       out
;         First value is DC, unless freq is requested.
; COMMON BLOCKS:
;       cspec_com
; NOTES:
;       Notes: For example, if Z=I+iQ, and I and Q are in volts,
;         s will be volts**2/Hz
;         Restrictions: one dimensional data only.
; MODIFICATION HISTORY:
;       B. L. Gotwols Oct. 13, 1990.
;       R. E. Sterner Sep. 13, 1991 --- added freq and cleaned up.
;       R. E. Sterner Mar.  1, 1993 --- Tested for ntimes eq 0 sooner.
;       R. Sterner, 1994 Oct 31 --- added overlap
;       R. Sterner, 1994 Nov, 10 --- Added ZEROPAD keyword.
;       R. Sterner, 2004 Jun 01 --- Fixed freq0 in case n is not integer.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
 
	function cspec,z,n,sr,freq, overlap=novr0, n_ensemble=n_en, $
	  help=hlp, notes=notes, zeropad=zlen
 
	common cspec_com, nlast,srlast,w,freq0,hannratio,zlast,zero,slen 
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  if not keyword_set(notes) then begin
	  print,' Compute ensemble averaged frequency spectrum of complex data.'
	  print,' s = cspec(z,n,sr,[freq])'
	  print,'   z = input signal: Z = X + iY.                   in'
	  print,'     If z has too few points, -1 is returned.'
	  print,'   n = number of points to use in each transform   in'
	  print,'     May be arbitrary.'
	  print,'   sr = sample rate in Hz                          in'
	  print,'     Needed to get actual units'
	  print,'   freq = optionally output frequency array.       out'
	  print,'     If freq is requested then s is shifted for plots.'
	  print,'   s = spectral density in units of z**2/Hz.       out'
	  print,'     First value is DC, unless freq is requested.'
	  print,' Keywords:'
          print,'   OVERLAP=novr  number of points to overlap spectra (Def=0).'
          print,'   ZEROPAD=zlen  length to zero pad out to (def=no 0 pad).'
          print,'   N_ENSEMBLE=n  returned # spectra ensemble averaged.'
	  print,'   /NOTES lists some additional comments.'
	  print,' Notes: For example, if Z=I+iQ, and I and Q are in volts,'
	  print,'   s will be volts**2/Hz'
	  print,'   Restrictions: one dimensional data only.'
	  return,-1
	  endif
	endif
 
	if keyword_set(notes) then begin
	  print,'   Procedure: s = cspec(z,n,sr)'
	  print,'     where the complex data to be analyzed is in z.'
	  print,'   Note that the returned spectrum is two sided in frequency.'
	  print,'   A Hanning window has been applied to each transform, and a'
	  print,'   multiplicative correction applied to compensate for the'
	  print,"   window.  Ignoring the window's effects, the mean sq. can"
	  print,'   be recovered by ms = (sr/n) * (sum[i = 1 to n - 1]s(i))'
	  print,'   The sr/n term converts from analog continuum spectral'
	  print,'   density to total bandpassed mean square.  There may be'
	  print,'   data left out of the ensemble if the number of elements'
	  print,'   in z is not an integral multiple of n. This is not'
	  print,'   harmful.'
	  print,'   NOTE: the spectrum is approximately corrected for the'
	  print,'   Hanning window with a constant 8/3 factor rather than'
	  print,'   an empirically derived factor as in an older routine.'
	  print,'   With the older routine, unresolved low frequency trends'
	  print,'   gave a factor that is incorrect for the second and'
	  print,'   higher harmonics.  Thus the constant factor seems a'
	  print,'   better compromise, although now the fundamental may be'
	  print,'   off and the mean square will no longer be exactly'
	  print,'   recovered by integrating the spectrum.  The DC term is '
	  print,'   handled seperately in order to avoid corrupting the low '
	  print,'   frequency components.'
	  return, -1
	endif
 
        ;---------  Set default values  ---------------
        if n_elements(novr0) eq 0 then novr0 = 0         ; Def=0 overlap.
        novr = long(novr0)                               ; Force long.
	if n_elements(zlen) eq 0 then zlen = 0           ; No 0 pad.
 
	;------  Update common if needed  ---------
	if n_elements(nlast) eq 0 then nlast = 0
	if n_elements(srlast) eq 0 then srlast = 0
        if n_elements(zlast) eq 0 then zlast = 0
	if (n ne nlast) or (sr ne srlast) or (zlen ne zlast) then begin
	  nlast = n			; Remember spectrum length.
	  srlast = sr			; Remember sample rate.
	  zlast = zlen                  ; Remember zero pad length.
	  ;-------  Hanning weighting array  ---------
	  w=costap(n,0.)  		; Hanning weights
	  hannratio = 8./3.		; Hann window correction factor
	  ;-------  Make frequency array  ------------
	  slen = n>zlen                 ; Spectra length.
	  ny = sr/2.			; Nyquist freq = 1/2 sample rate.
	  df = ny/(slen/2.)	; Step size in freq: ny occurs at index n/2.
;	  freq0 = (findgen(slen)-slen/2)*df  	; Array frequencies.
	  freq0 = (findgen(slen)-long(slen/2))*df  ; Array frequencies.
	  ;-------  Zero pad array  -----------
	  if zlen gt 0 then zero = complexarr(zlen) ; Zero pad array.
	endif
 
	;------  Return frequency array only if requested  ------
	if n_params(0) ge 4 then freq=freq0
 
	;-------  Setup to compute spectra  --------
	nl = long(n)			; We want this to be a long int.
	s = fltarr(slen)		; Spectrum accumulator.
	np = n_elements(z)              ; Total points in z.
	nstep = n - novr                ; Step novr less than # pts in spect.
	nt = np - novr                  ; Total # usable points.
	ntimes = nt/nstep		; Number of spectra to ensemble average
	n_en = ntimes                   ; Return # spectra ensemble averaged.
	if ntimes eq 0 then return,-1	; Return a -1 error flag.
	nused = ntimes*nstep+novr	; Number of points we actually use.
	zmean = mean(z(0:nused-1))	; Mean of the data we use.
 
	;-------  Do ensemble averaged spectrum  ---------
	for i= 0L,ntimes-1 do begin
	  lo = i*nstep			; Data start index.
	  hi = lo + n - 1		; Data end index.
	  y = z(lo:hi)			; Isolate the data to transform.
	  ymean = mean(y)		; Save the unwindowed mean.
	  y = y-ymean			; Subtract the mean.
	  if zlen eq 0 then begin
	    y = y*w			; Apply the data window.
	    fy = fft(y,-1)		; Take the fft.
	  endif else begin
	    zero(0) = y*w		; Apply the data window, 0 pad.
	    fy = fft(zero,-1)           ; Take the fft.
	  endelse
	  s = s+(float(fy*conj(fy)))	; Accumulate the spectra.
	endfor
 
	;-----  average spectral density taking account of IDL's 1/n
	;-----  factor for the forward transform, and correcting for
	;-----  the effect of the Hanning window.
	s = (s/ntimes)*(float(slen)/sr)*hannratio
 
	;---  Put the DC term back in  ---
	s(0) = slen*(float(zmean)^2+imaginary(zmean)^2)/sr
	if n_params(0) ge 4 then s = shift(s,slen/2)
	return,s
 
	end
