;-------------------------------------------------------------
;+
; NAME:
;       LS2
; PURPOSE:
;       Scale image between percentiles 1 and 99 (or specified percentiles).
; CATEGORY:
; CALLING SEQUENCE:
;       out = ls2(in, [l, u, alo, ahi])
; INPUTS:
;       in = input image.                           in
;         Byte, Int, and Uint scale to full data type range.
;         by default.  Other data types scale to 0 to 255
;         by default. However, a floating result is returned.
;       l = lower percentile to ignore (def = 1).   in
;       u = upper percentile to ignore (def = 1).   in
; KEYWORD PARAMETERS:
;       Keywords:
;         MIN=mnout Output image min value.
;         MAX=mxout Output image max value.
;           Default min and max are full datatype range.
;         SCALE_ON=arr  Array to determine scaling on.  If not
;           given then input image in is used. As a special case
;           may give a 2 element array: [lo,hi] to scale to min, max.
;         /QUIET  Inhibit scaling message.
;         /NOSCALE  Do not actually scale the data (returns 0).
;       MISSING=miss Values to ignore for processing.  Restore
;         when done.  Note: MISSING applies to the input image
;         array, not the SCALE_ON array if given.
;       WMISS=wmiss  1-d indices into each color component
;         where data missing (-1 if no missing data).
;       WGOOD=wgood  1-d indices into each color component
;         where data is good.
;         NBINS=nbins Number of histogram bins to use (def=600).
; OUTPUTS:
;       alo = value scaled to min                   out
;       ahi = value scaled to max                   out
;       out = scaled image.                         out
; COMMON BLOCKS:
; NOTES:
;       Notes: Uses cumulative histogram.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jun 21
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function ls2, a, l, u, alo, ahi, help=hlp, $
	  scale_on=scale_on, quiet=quiet, noscale=noscale, $
	  nbins=nbins0, missing=miss, wmiss=wmiss, wgood=wg, $
	  min=mnout, max=mxout
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Scale image between percentiles 1 and 99 '+$
	    '(or specified percentiles).'
	  print,' out = ls2(in, [l, u, alo, ahi])'
	  print,'   in = input image.                           in'
	  print,'     Byte, Int, and Uint scale to full data type range.'
	  print,'     by default.  Other data types scale to 0 to 255'
	  print,'     by default. However, a floating result is returned.'
	  print,'   l = lower percentile to ignore (def = 1).   in'
	  print,'   u = upper percentile to ignore (def = 1).   in'
	  print,'   alo = value scaled to min                   out'
	  print,'   ahi = value scaled to max                   out'
	  print,'   out = scaled image.                         out'
	  print,' Keywords:'
	  print,'   MIN=mnout Output image min value.'
	  print,'   MAX=mxout Output image max value.'
	  print,'     Default min and max are full datatype range.'
	  print,'   SCALE_ON=arr  Array to determine scaling on.  If not'
	  print,'     given then input image in is used. As a special case'
	  print,'     may give a 2 element array: [lo,hi] to scale to min, max.'
	  print,'   /QUIET  Inhibit scaling message.'
	  print,'   /NOSCALE  Do not actually scale the data (returns 0).'
	  print,' MISSING=miss Values to ignore for processing.  Restore'
	  print,'   when done.  Note: MISSING applies to the input image'
	  print,'   array, not the SCALE_ON array if given.'
	  print,' WMISS=wmiss  1-d indices into each color component'
	  print,'   where data missing (-1 if no missing data).'
	  print,' WGOOD=wgood  1-d indices into each color component'
	  print,'   where data is good.'
	  print,'   NBINS=nbins Number of histogram bins to use (def=600).'
	  print,' Notes: Uses cumulative histogram.'
	  return, ''
	endif
 
	;--------  Check image type and set default scaling range  ---------
	typ = datatype(a, numeric=num)
	case typ of
'BYT':	begin
	  x_mn = 0
	  x_mx = 255
	end
'INT':	begin
	  x_mn = -32768
	  x_mx = 32767
	end
'UIN':	begin
	  x_mn = 0
	  x_mx = 65535
	end
else:   begin
	  if (num gt 0) and (num lt 3) then begin
	    x_mn = 0
	    x_mx = 255
	  endif else begin
	    print,' Error in ls2: given datatype not allowed ('+typ+').'
	    return, -1	
	  endelse
	end
	endcase
 
	;---------  Set Defaults  ------------------
	if n_elements(l) eq 0 then l=1
	if n_elements(u) eq 0 then u=1
	clo = l/100.			; Lower fraction of cumulative hist.
	chi = (100.-u)/100.		; Upper fraction of cumulative hist.
	if n_elements(mnout) eq 0 then mnout=x_mn
	if n_elements(mxout) eq 0 then mxout=x_mx
	if n_elements(nbins0) eq 0 then nbins0=600
	nbins = float(nbins0)
 
	;-------  Deal with MISSING (w = good elements) -----
	if n_elements(miss) eq 0 then begin	; Use all image values.
	  cnt = n_elements(a)			; Number of elements.
	  w = lindgen(cnt)			; Indices of all elements.
	  wg = w				; Returned where good indices.
	  wmiss = -1				; No missing values.
	  if n_elements(scale_on) ne 0 then begin  ; Handle SCALE_ON.
	    w = lindgen(n_elements(scale_on))
	  endif
	endif else begin
	  w = where(a ne miss,cnt)		; Indices of good values.
	  wg = w				; Returned where good indices.
	  wmiss = where(a eq miss,cnt)		; Indices of missing values.
	  if n_elements(scale_on) ne 0 then begin  ; Handle SCALE_ON.
	    w = where(scale_on ne miss)
	  endif
	endelse
 
	;-------  Bin data  -----------------------------------
	if n_elements(scale_on) eq 0 then begin	; Scale on input image.
	  amn = min(a(w))			; Find array extremes.
	  amx = max(a(w))
	  da = amx - amn			; Array range.
	  if da eq 0 then goto, constant	; Error.
	  h = hist(a(w),x,nbins=nbins)		; Do histogram.
	endif else begin			; Scale on given array.
	  amn = min(scale_on)			; Find array extremes.
	  amx = max(scale_on)
	  da = amx - amn                        ; Array range.
	  if da eq 0 then goto, constant	; Error.
	  if n_elements(scale_on) eq 2 then begin
	    b = scalearray(a>amn<amx,amn,amx,mnout,mxout)  ; scale array.
	    return, b
	  endif
	  h = hist(scale_on(w),x,nbins=nbins)	; Do histogram.
	endelse
 
	;--------  Process histogram  ---------------------
	c = cumulate(h)				; Look at cumulative histogram.
	c = float(c)/max(c)			; Normalize.
	w = where((c gt clo) and (c lt chi),count)	; Pick central window.
	if count gt 0 then begin
	  alo = x(min(w))			; find limits of rescaled data.
	  ahi = x(max(w))
	  if l eq 0 then alo=amn		; Special case for no cutoff.
	  if u eq 0 then ahi=amx
	endif else begin
	  alo = min(x)
	  ahi = max(x)
	  if not keyword_set(quiet) then print,$
	    ' LS2 Warning: could not scale array properly.'
	endelse
	if not keyword_set(quiet) then print,$
	  ' Scaling image from ',alo,' to ',ahi
	if keyword_set(noscale) then return, 0	; Skip scaling.
	b = scalearray(a>alo<ahi,alo,ahi,mnout,mxout)
	return, b
 
constant:
	print,' Error in ls2: given array is constant, no stretch possible.'
	return, bytscl(a)
 
	end
