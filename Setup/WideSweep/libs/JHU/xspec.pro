;-------------------------------------------------------------
;+
; NAME:
;       XSPEC
; PURPOSE:
;       Compute an ensemble averaged cross spectrum of real data.
; CATEGORY:
; CALLING SEQUENCE:
;       sxy = xspec(x,y,n,sr,[freq])
; INPUTS:
;       x = input signal number 1.                      in
;       y = input signal number 2.                      in
;         If x or y have too few points, -1 is returned.
;       n = number of points to use in each transform   in
;         May be arbitrary.
;       sr = sample rate in Hz (Def=1 Hz)               in
;         Needed to get actual units.
; KEYWORD PARAMETERS:
;       Keywords:
;         OVERLAP=novr  number of points to overlap spectra.
;           (Def=0).
;         TRANSFER_FUNCT = transfer function, Txy = Sxy/Sxx
;           in units of y/x
;         CA_ARRAY = ca :  Coherence and autospectra array.
;           ca(*,0)=Cxy(f)  Coherence=|Sxy|^2/(Sxx*Syy) dimensnless
;           ca(*,1) = Sxx(f)  Autospectrum of x in units of x**2/Hz.
;           ca(*,2) = Syy(f)  Autospectrum of y in units of y**2/Hz.
;         N_ENSEMBLE=n  returned # spectra ensemble averaged.
;         /NOTES lists some additional comments.
; OUTPUTS:
;       sxy = spectral density in units of x*y/Hz.      out
;         First value is DC, last is Nyquist.
;       freq = optionally output frequency array.       out
; COMMON BLOCKS:
;       xspec_com
; NOTES:
;       Notes: Restricted to one dimensional data only.
;         Reference: 
; MODIFICATION HISTORY:
;       B. L. Gotwols Mar. 1, 1993
;       R. E. Sterner Mar. 1, 1993 --- cleaned up some.
;       BLG, RES ---  Mar. 10, 1993 --- renamed variables.
;       BLG --- 19 May, 1993 --- made loop index long.
;       Fixed ntimes to be correct.  Also floated sr.
;       Made OVERLAP default to 0 to be consistent with
;       future addition of OVERLAP in rspec and cspec.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function xspec, x, y, n0, sr0, freq, overlap=novr0,  n_ensemble=n_en, $
	    ca_array=ca, transfer_funct=txy, help=hlp, notes=notes
 
	common xspec_com, nlast, srlast, w, freq0, hannratio
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  if not keyword_set(notes) then begin
	  print,' Compute an ensemble averaged cross spectrum of real data.'
	  print,' sxy = xspec(x,y,n,sr,[freq])'
	  print,'   x = input signal number 1.                      in'
	  print,'   y = input signal number 2.                      in'
	  print,'     If x or y have too few points, -1 is returned.'
	  print,'   n = number of points to use in each transform   in'
	  print,'     May be arbitrary.'
	  print,'   sr = sample rate in Hz (Def=1 Hz)               in'
	  print,'     Needed to get actual units.'
	  print,'   sxy = spectral density in units of x*y/Hz.      out'
	  print,'     First value is DC, last is Nyquist.'
          print,'   freq = optionally output frequency array.       out'
	  print,' Keywords:'
	  print,'   OVERLAP=novr  number of points to overlap spectra.'
	  print,'     (Def=0).'
	  print,'   TRANSFER_FUNCT = transfer function, Txy = Sxy/Sxx'
	  print,'     in units of y/x
	  print,'   CA_ARRAY = ca :  Coherence and autospectra array.'
	  print,'     ca(*,0)=Cxy(f)  Coherence=|Sxy|^2/(Sxx*Syy) dimensnless'
	  print,'     ca(*,1) = Sxx(f)  Autospectrum of x in units of x**2/Hz.'
	  print,'     ca(*,2) = Syy(f)  Autospectrum of y in units of y**2/Hz.'
	  print,'   N_ENSEMBLE=n  returned # spectra ensemble averaged.'
	  print,'   /NOTES lists some additional comments.'
	  print,' Notes: Restricted to one dimensional data only.'
	  print,'   Reference: '
	  return,-1
	  endif
	endif
 
	if keyword_set(notes) then begin
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
 
        ;------  Update common if needed  ---------
        if n_elements(nlast) eq 0 then nlast = 0
        if n_elements(srlast) eq 0 then srlast = 0
        if (n ne nlast) or (sr ne srlast) then begin
          nlast = n                     ; Remember spectrum length.
          srlast = sr                   ; Remember sample rate.
          w=costap(n,0.)                ; Hanning weights
          hannratio = 8./3.             ; Hann window correction factor
          ;-------  Make frequency array  ------------
          ny = sr/2.                    ; Nyquist freq = 1/2 sample rate.
          df = ny/(n/2.)        ; Step size in freq: ny occurs at index n/2.
	  freq0 = findgen(1+(n/2))*df  ; Array frequencies.
        endif
 
        ;------  Return frequency array only if requested  ------
        if n_params(0) ge 5 then freq = freq0
 
	;------  Set up storage  --------------
	sxx = fltarr(n)			; Cospectra of x.
	syy = fltarr(n)			; Cospectra of y.
	sxy=complexarr(n)		; Cross spectrum.
	txy = complexarr(n/2+1)		; Transfer function.
	ca = fltarr(n/2+1,3)		; Coherence and cospectra.
 
	;----------  Find some preliminary values  ------------
 	nl=long(n)			; We want this to be a long int.
	nx = n_elements(x)		; Total points in x.
	ny = n_elements(y)		; Total points in y.
	np = nx<ny			; Smallest array sets total # points.
	nstep = n - novr		; Step novr less than # pts in spect.
	nt = np - novr			; Total # usable points.
	ntimes = nt/nstep		; Number of spectra to ensemble average
	n_en = ntimes			; Return # spectra ensemble averaged.
	if ntimes eq 0 then return,-1	; Return a -1 error flag
	nused = ntimes*nstep + novr	; Number of points we actually use
	xmean = mean(x(0:nused-1))	; Overall mean of the data we use
	ymean = mean(y(0:nused-1))
 
	;-----  Ensemble average the data  ----------------
	for i= 0L,ntimes-1 do begin
	  lo = i*nstep			; Data start index.
	  hi = lo + n - 1		; Data end index.
	  xx = x(lo:hi)			; Isolate the data to transform
	  yy = y(lo:hi)
	  xx = (xx-mean(xx))*w		; subtract the mean and apply window
	  yy = (yy-mean(yy))*w
	  fxx = fft(xx,-1)		; take the fft
	  fyy = fft(yy,-1)
	  sxx = sxx + float(fxx*conj(fxx))  ; accumulate the spectra
	  syy = syy + float(fyy*conj(fyy))
	  sxy = sxy + conj(fxx)*fyy
	endfor
 
	;-------  average spectral density taking ccount of IDL's 1/n factor
	;-------  for the forward transform, and correcting for the effect of
	;-------  the Hanning window.
	sxx = (sxx/ntimes)*(n/sr)*hannratio
	syy = (syy/ntimes)*(n/sr)*hannratio
	sxy = (sxy/ntimes)*(n/sr)*hannratio	; Cross spectrum
	;-------  Restore DC term  -------------
	sxx(0) = (n*xmean^2)/sr
 	syy(0) = (n*ymean^2)/sr
	sxy(0) = (n*xmean*ymean)/sr
	;-------  Transfer function, Coherence, Cospectra  ------
	txy(1) = sxy(1:n/2)/sxx(1:n/2)
	ca(1,0) = abs(sxy(1:n/2))^2/(sxx(1:n/2)*syy(1:n/2))
	ca(0,1) = sxx(0:n/2)
	ca(0,2) = syy(0:n/2)
 
	return,sxy(0:n/2)		; Return one side: DC to Nyquist.
 
	end
