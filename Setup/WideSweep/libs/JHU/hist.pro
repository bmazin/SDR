;-------------------------------------------------------------
;+
; NAME:
;       HIST
; PURPOSE:
;       Compute histogram and corresponding x values. Allows weights.
; CATEGORY:
; CALLING SEQUENCE:
;       h = hist(a, [x, bin])
; INPUTS:
;       a = input array.                             in
;       bin = optional bin size.                     in
;         Def is a size to give about 30 bins.
;         NBINS over-rides bin value and returns value used.
; KEYWORD PARAMETERS:
;       Keywords:
;         MINH=mn  sets min histogram value.
;         MAXH=mx  sets max histogram value.
;         /EXACT means use MINH and MAXH exactly. Else
;           adjusts so histogram goes to 0 at ends.
;         /BIN_START means return x as bin start values,
;           else x is returned as bin mid values.
;         MAXBINS = mx.  Set max allowed number of bins to mx.
;           Over-rides default max of 1000.
;         NBINS = n.  Set number of bins used to about n.
;           Actual bin size is a nice number giving about n bins.
;           Over-rides any specified bin size.
;         WEIGHT=wt Array of weights for each input array element.
;           If this is given then the weights are summed for each
;           bin instead of the counts.  Returned histogram is a
;           floating array.  Slower.
; OUTPUTS:
;       x = optionally returned array of x values.   out
;       h = resulting histogram.                     out
; COMMON BLOCKS:
; NOTES:
;       Notes: the boundaries of the histogram bins are positioned
;         as follows: [...,-2*bin,-bin,0,bin,2*bin,...].
;         To be compatable with plot,x,h,psym=10 the returned x
;         array has values at the bin centers, that is:
;         [...,-2.5*bin,-1.5*bin,-.5*bin,.5*bin,1.5*bin,...].
;         This may be over-ridden using the /BIN_START keyword
;         which returns the X array with the bin starting X instead
;         of the bin center.
; MODIFICATION HISTORY:
;       R. Sterner. Converted to SUN 11 Dec, 1989.
;       R. Sterner. Added MINH, MAXH, EXACT, and BIN_START, 14 Aug, 1991.
;       R. Sterner. Fixed integer overflow problem for bin size. 2 Oct, 1992.
;       R. Sterner. Added weighted histogram. 1994 Jan 27.
;       M. R. Keller. Fixed integer/float problem for binsize test. 27 Jan 2003.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	function hist, arr, x, bin, help=hlp, maxbins=mxb, nbins=nb, $
	  minh=minv, maxh=maxv, exact=exact, bin_start=bin_start, weight=wt
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Compute histogram and corresponding x values. Allows weights.'
	  print,' h = hist(a, [x, bin])'
	  print,'   a = input array.                             in'
	  print,'   x = optionally returned array of x values.   out'
	  print,'   bin = optional bin size.                     in'
	  print,'     Def is a size to give about 30 bins.'
	  print,'     NBINS over-rides bin value and returns value used.'
	  print,'   h = resulting histogram.                     out'
	  print,' Keywords:'
	  print,'   MINH=mn  sets min histogram value.'
	  print,'   MAXH=mx  sets max histogram value.'
	  print,'   /EXACT means use MINH and MAXH exactly. Else'
	  print,'     adjusts so histogram goes to 0 at ends.'
	  print,'   /BIN_START means return x as bin start values,'
	  print,'     else x is returned as bin mid values.'
	  print,'   MAXBINS = mx.  Set max allowed number of bins to mx.'
	  print,'     Over-rides default max of 1000.'
	  print,'   NBINS = n.  Set number of bins used to about n.'
	  print,'     Actual bin size is a nice number giving about n bins.'
	  print,'     Over-rides any specified bin size.'
	  print,'   WEIGHT=wt Array of weights for each input array element.'
	  print,'     If this is given then the weights are summed for each'
	  print,'     bin instead of the counts.  Returned histogram is a'
	  print,'     floating array.  Slower.'
	  print,' Notes: the boundaries of the histogram bins are positioned'
	  print,'   as follows: [...,-2*bin,-bin,0,bin,2*bin,...].'
	  print,'   To be compatable with plot,x,h,psym=10 the returned x'
	  print,'   array has values at the bin centers, that is:'
	  print,'   [...,-2.5*bin,-1.5*bin,-.5*bin,.5*bin,1.5*bin,...].'
	  print,'   This may be over-ridden using the /BIN_START keyword'
	  print,'   which returns the X array with the bin starting X instead'
	  print,'   of the bin center.'
	  return, -1
	endif
 
	;------  If bin size not given pick one  --------
	if n_params(0) lt 3 then $
	  bin = nicenumber((double(max(arr))-double(min(arr)))/30.)
	if keyword_set(nb) then $
	  bin = nicenumber((double(max(arr))-double(min(arr)))/nb)
	;------  Get max number of bins allowed  --------
	mxbins = 1000L				; Def max # of histogram bins.
	if keyword_set(mxb) then mxbins = mxb	; Over-ride max bins.
	;------  Get histogram min and max values  ------
 	mn = min(arr, max = mx)			; Min,max array value.
	if n_elements(minv) ne 0 then mn = minv	; Set min.
	if n_elements(maxv) ne 0 then mx = maxv	; Set max.
	b2 = bin/2.0				; Bin half width.
	xmn = bin*floor(mn/bin)			; First bin start X.
	xmx = bin*(1+floor(mx/bin))		; Last bin end X.
	n = long((xmx - xmn)/bin)		; Number of histogram bins.
	;------  Test if too many bins  --------
	if n gt mxbins then begin
	  print,' Error in HIST: bin size too small, histogram requires '+$
	    strtrim(n,2)+' bins.'
	  print,' Def.max # of bins = 1000.  May over-ride with NBINS keyword.'
	  return, -1
	endif
 
	;--------  Weighted histogram?  ----------------------------
	if n_elements(wt) ne 0 then begin
	  if n_elements(wt) ne n_elements(arr) then begin
	    print,' Error in hist: when weights are given there must be one'
	    print,'   for each input array element.'
	    return,-1
	  endif
	  h = fltarr(n)
	  i = long((arr - xmn)/bin)
	  for j=0, n_elements(arr)-1 do h(i(j)) = h(i(j)) + wt(j)
	endif else begin
	  ;--------  Make histogram and bin X coordinates  ----------- 
	  h = histogram((arr - xmn)/bin, min=0, max=n)
	  h = h(0:n-1)				; Trim upper end.
	endelse
 
	x = xmn + bin*findgen(n_elements(h))	; Bin starting x coordinates.
 
	;-------  Adjust histogram ends  ---------
	if not keyword_set(exact) then begin
	  x = [min(x)-bin,x,max(x)+bin]		; Add a bin to each end so
	  h = [0,h,0]				; histogram drops to 0 on ends.
	endif
 
	;-------  Adjust bin values  ---------
	if not keyword_set(bin_start) then x = x + b2  ; Mid bin x coordinates.
 
	return, h
	end
