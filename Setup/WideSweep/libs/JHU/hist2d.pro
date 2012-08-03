;-------------------------------------------------------------
;+
; NAME:
;       HIST2D
; PURPOSE:
;       Compute a 2-d histogram for an array of points.
; CATEGORY:
; CALLING SEQUENCE:
;       h2d = hist2d( x, y)
; INPUTS:
;       x, y = 2-d point coordinates.                 in
; KEYWORD PARAMETERS:
;       Keywords:
;         MIN=mn set lower left corner of region to
;           histogram in (x,y) space.  If x and y are
;           of type byte the default is 0.  If MIN is not
;           given and type is not byte then the arrays are
;           searched for their min values.  If MIN is a scalar
;           or 1 element array then that value is applied to both
;           x and y.  To set both x and y minimums separately
;           send MIN as the d element array [xmin, ymin].
;         MAX=mx set upper right corner of region to
;           histogram in (x,y) space.  If MAX is not given then
;           the arrays are searched for their max values. If MAX
;           is scalar or 1 element array that value is applied to
;           both x and y.  To set both x and y maximums separately
;           send MAX as the 2 element array [xmax, ymax].
;         BIN=bn sets the histogram bin widths.  If BIN is a
;           scalar or a single element array then it is applied
;           to both x and y.  To set both x and y bins separately
;           send BIN as the 2 element array [xbin, ybin].
;           If BIN is not given then a value is chosen to give
;           roughly 200 bins in both x and y.
;         /LIST lists the x and y ranges and bin sizes used
;           to compute the 2-d histogram.
;         OUT=out Returned structure with x and y axes arrays
;           and x and y bin widths.
; OUTPUTS:
;       h2d = The computed 2-d histogram of x and y.  out
; COMMON BLOCKS:
;       array_map_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 24 May, 1991.
;       R. Sterner, 2005 Jan 04 --- Added new keyword OUT.
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function hist2d, x, y, min=mn, max=mx, bin=bn, help=hlp, $
	  list=list, out=out
 
	common array_map_com, amxmn, amxstep, amymn, amystep
 
	if (n_params(0) eq 0) or keyword_set(hlp) then begin
	  print,' Compute a 2-d histogram for an array of points.'
	  print,' h2d = hist2d( x, y)'
	  print,'   x, y = 2-d point coordinates.                 in'
	  print,'   h2d = The computed 2-d histogram of x and y.  out'
	  print,' Keywords:'
	  print,'   MIN=mn set lower left corner of region to'
	  print,'     histogram in (x,y) space.  If x and y are'
	  print,'     of type byte the default is 0.  If MIN is not'
	  print,'     given and type is not byte then the arrays are'
	  print,'     searched for their min values.  If MIN is a scalar'
	  print,'     or 1 element array then that value is applied to both'
	  print,'     x and y.  To set both x and y minimums separately'
	  print,'     send MIN as the d element array [xmin, ymin].'
	  print,'   MAX=mx set upper right corner of region to'
	  print,'     histogram in (x,y) space.  If MAX is not given then'
	  print,'     the arrays are searched for their max values. If MAX'
	  print,'     is scalar or 1 element array that value is applied to'
	  print,'     both x and y.  To set both x and y maximums separately'
	  print,'     send MAX as the 2 element array [xmax, ymax].'
	  print,'   BIN=bn sets the histogram bin widths.  If BIN is a'
	  print,'     scalar or a single element array then it is applied'
	  print,'     to both x and y.  To set both x and y bins separately'
	  print,'     send BIN as the 2 element array [xbin, ybin].'
	  print,'     If BIN is not given then a value is chosen to give'
	  print,'     roughly 200 bins in both x and y.'
	  print,'   /LIST lists the x and y ranges and bin sizes used'
	  print,'     to compute the 2-d histogram.'
	  print,'   OUT=out Returned structure with x and y axes arrays'
	  print,'     and x and y bin widths.'
	  return, -1
	endif
 
	;======  Process keywords  =======
	;------  MIN  -------
	if n_elements(mn) eq 0 then begin	; No MIN.
	  xmn = 0.				; Assume data type = byte.
	  ymn = 0.
	  sz = size(x)				; Check assumption.
	  if sz(sz(0)+1) ne 1 then begin	; Type byte?
	    xmn = min(x)			; No, search for mins.
	    ymn = min(y)
	  endif
	endif else begin
	  xmn = mn(0)				; Use given MIN.
	  ymn = mn((1<(n_elements(mn)-1)))
	endelse
 
	;------  MAX  -------
	if n_elements(mx) eq 0 then begin	; No MAX.
	  xmx = max(x)				; Search for max.
	  ymx = max(y)
	endif else begin
	  xmx = mx(0)				; Use given MAX.
	  ymx = mx((1<(n_elements(mx)-1)))
	endelse
 
	;------  BIN  -------
	if n_elements(bn) eq 0 then begin	; No BIN.
	  xbin = nicenumber((xmx-xmn)/200.)	; Pick bins to make 2-d
	  ybin = nicenumber((ymx-ymn)/200.)	; hist be about 200 x 200.
	endif else begin
	  xbin = bn(0)				; Use given BIN.
	  ybin = bn((1<(n_elements(bn)-1)))
	endelse
 
 
	;========  Process data  ==========
	;-----  Size of 2-d histogram  --------
	nx = long((xmx - xmn)/xbin)
	ny = long((ymx - ymn)/ybin)
	n = nx*ny
 
	;-----  Find data that is in range  ---------
	w = where((x ge xmn) and (x le xmx) and $
	          (y ge ymn) and (y le ymx), count)
	if count le 0 then begin
	  print,' Error in hist2d: no data in selected range,'
	  print,'   check MIN and MAX keywords.'
	  return, -1
	endif
 
	;-----  Convert data to 2-d histogram indices  -------
	ix = long((x(w)-xmn)/xbin)
	iy = long((y(w)-ymn)/ybin)
	two2one, ix, iy, [nx,ny], in	; Convert from 2-d indices to 1-d.
	h = histogram(in,min=0,max=n-1) ; Count occurrances of 1-d indices.
 
	;-----  /LIST  ---------
	if keyword_set(list) then begin
	  print,' Values used to compute the 2-d histogram:'
	  print,'   xmin, xmax, xbin = ',xmn, xmx, xbin
	  print,'   ymin, ymax, ybin = ',ymn, ymx, ybin
	endif
 
	;-----  Set values in common  ---------
	amxmn = xmn		; This values may be used to
	amxstep = xbin		; convert array coordinates to
	amymn = ymn		; some linear mapping.
	amystep = ybin
 
	;-----  Return axes values  -----------
	if arg_present(out) then begin
	  xax = xmn + findgen(nx)*xbin
	  yax = ymn + findgen(ny)*ybin
	  out = {xax:xax, yax:yax, xbin:xbin, ybin:ybin, $
	    xmn:xmn, xmx:xmx, ymn:ymn, ymx:ymx, nx:nx, ny:ny}
	endif
 
	return, reform(h, nx, ny)
 
	end
