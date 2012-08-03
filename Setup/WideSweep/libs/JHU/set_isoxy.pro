;-------------------------------------------------------------
;+
; NAME:
;       SET_ISOXY
; PURPOSE:
;       Set data window with equal x & y scales. Covers at least given range
; CATEGORY:
; CALLING SEQUENCE:
;       set_isoxy, xmn, xmx, ymn, ymx
; INPUTS:
;       xmn, xmx = desired min and max X.        in
;       ymn, ymx = desired min and max Y.        in
; KEYWORD PARAMETERS:
;       Keywords:
;         CHARSIZE=csz  Character size for axis labels (def=1).
;         /LIST = list actual window that is set.
;         XLOCK = position where position is one of
;                 'xmn' to extend window upward from the min x.
;                 'xmd' to extend window outward from the mid x.
;                 'xmx' to extend window downward from the max x.
;         YLOCK = position where position is one of
;                 'ymn' to extend window upward from the min y.
;                 'ymd' to extend window outward from the mid y.
;                 'ymx' to extend window downward from the max y.
;         NXRANGE = [nx_min, nx_max] sets x pos. in norm. coord.
;                 Min and max normalized x.  Def = [0., 1.]
;         NYRANGE = [ny_min, ny_max] sets y pos. in norm. coord.
;                 Min and max normalized y.  Def = [0., 1.]
;         LATITUDE=lat If given will set equal scaling based on
;           given latitude.  Expands X range by 1/cos(lat).
;           Given latitudes not changed.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes:
;         Either xmn, xmx or ymn, ymx will be adjusted to force
;         equal scaling in X and Y in the current screen window.
;         At least the specified range will be covered in both X
;         and Y, but a greater range will be covered in one.
;         The window middle or corners may be fixed.
;         set_isoxy,0,0,0,0 (or set_isoxy,0) resets autoscaling.
; MODIFICATION HISTORY:
;       R. Sterner.  3 Sep, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 10 Sep, 1989 --- converted to SUN.
;       R. Sterner, 8 Nov, 1991 --- fixed !x.style,!y.style to
;       be reset on set_isoxy,0,0,0,0 and also allowed set_isoxy,0.
;       R. Sterner, 21 Apr, 1992 --- added a plot statement to
;       set scaling.  No plot is output.
;       R. Sterner, 1995 Jul 20 --- Added LATITUDE keyword.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro set_isoxy, xmn0, xmx0, ymn0, ymx0, xlock=xlck, ylock=ylck, $
	  list=lst, help=hlp, nxrange=nxr, nyrange=nyr, latitude=lat, $
	  charsize=csz
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Set data window with equal x & y scales. '+$
	    'Covers at least given range.
	  print,' set_isoxy, xmn, xmx, ymn, ymx'
	  print,'   xmn, xmx = desired min and max X.        in'
	  print,'   ymn, ymx = desired min and max Y.        in'
	  print,' Keywords:'
	  print,'   CHARSIZE=csz  Character size for axis labels (def=1).'
	  print,'   /LIST = list actual window that is set.'
	  print,"   XLOCK = position where position is one of"
	  print,"           'xmn' to extend window upward from the min x."
	  print,"           'xmd' to extend window outward from the mid x."
	  print,"           'xmx' to extend window downward from the max x."
	  print,"   YLOCK = position where position is one of"
	  print,"           'ymn' to extend window upward from the min y."
	  print,"           'ymd' to extend window outward from the mid y."
	  print,"           'ymx' to extend window downward from the max y."
	  print,'   NXRANGE = [nx_min, nx_max] sets x pos. in norm. coord.'
	  print,'           Min and max normalized x.  Def = [0., 1.]'
	  print,'   NYRANGE = [ny_min, ny_max] sets y pos. in norm. coord.'
	  print,'           Min and max normalized y.  Def = [0., 1.]'
	  print,'   LATITUDE=lat If given will set equal scaling based on'
	  print,'     given latitude.  Expands X range by 1/cos(lat).'
	  print,'     Given latitudes not changed.'
	  print,' Notes:'
	  print,'   Either xmn, xmx or ymn, ymx will be adjusted to force'
	  print,'   equal scaling in X and Y in the current screen window.'
	  print,'   At least the specified range will be covered in both X'
	  print,'   and Y, but a greater range will be covered in one.'
	  print,'   The window middle or corners may be fixed.'
	  print,'   set_isoxy,0,0,0,0 (or set_isoxy,0) resets autoscaling.'
	  return
	endif 
 
	if n_elements(csz) eq 0 then csz=1.
	if n_elements(xlck) eq 0 then xlck = 'xmd'	; defaults.
	if n_elements(ylck) eq 0 then ylck = 'ymd'
	xlck = strupcase(xlck)
	ylck = strupcase(ylck)
 
	if n_elements(xmx0) eq 0 then xmx0 = 0
	if n_elements(ymn0) eq 0 then ymn0 = 0
	if n_elements(ymx0) eq 0 then ymx0 = 0
 
	xmn = xmn0				; copy so changing values
	xmx = xmx0				; won't change them in caller.
	ymn = ymn0
	ymx = ymx0
 
	if total(abs([xmn,xmx,ymn,ymx])) eq 0.0 then begin  ; Set to autoscale.
	  !x.range = 0
	  !y.range = 0
	  !x.style = 0
	  !y.style = 0
	  return
	endif
 
	plotwin, xx, yy, x_size, y_size, chars=csz	; True plot window.
	if n_elements(nxr) eq 0 then nxr = [0., 1.]	; Force norm window to
	if n_elements(nyr) eq 0 then nyr = [0., 1.]	;   be defined.
	x_size = x_size*(nxr(1)-nxr(0))			; Size of norm. window.
	y_size = y_size*(nyr(1)-nyr(0))
 
	idx = float(x_size)			; Screen window side lengths.
	idy = float(y_size)
 
	dx = float(xmx - xmn)			; Data window side lengths.
	dy = float(ymx - ymn)
	ymd = .5*(ymn + ymx)			; Data window midpoint.
	xmd = .5*(xmn + xmx)
 
	;-------  Deal with LATITUDE keyword  ----------
	if n_elements(lat) ne 0 then begin
	  dx2 = .5*dy*idx/idy			; Half new X range.
	  dy2 = .5*dy				; Half old Y range.
	  f = cos((lat<89.99>(-89.99))/!radeg)	; Correction factor.
	  dx2 = dx2/f				; Apply to x range.
	;------  No LATITUDE keyword  --------
	endif else begin
	  if (dx/dy) ge (idx/idy) then begin    ; Adjust Y range.
	    dy2 = .5*dx*idy/idx			; Half new Y range.
	    dx2 = .5*dx				; Half old X range.
	  endif else begin		      ; Adjust X range.
	    dx2 = .5*dy*idx/idy			; Half new X range.
	    dy2 = .5*dy				; Half old Y range.
	  endelse
	endelse
 
	;---------  lock window  -----------------
	case xlck of		  ; Lock x.
'XMN':	xmx = xmn + dx2 + dx2	  ; Lock x min.
'XMD':	begin			  ; Lock x mid.
	  xmn = xmd - dx2
	  xmx = xmd + dx2
	end
'XMX':	xmn = xmx - dx2 - dx2	  ; Lock x max.
	endcase
	case ylck of		  ; Lock y.
'YMN':	ymx = ymn + dy2 + dy2	  ; Lock y min.
'YMD':	begin			  ; Lock y mid.
	  ymn = ymd - dy2
	  ymx = ymd + dy2
	end
'YMX':	ymn = ymx - dy2 - dy2	  ; Lock y max.
	endcase
 
	set_window, xmn, xmx, ymn, ymx, nxrange=nxr, nyrange=nyr  ; full win.
	if keyword_set(lst) then begin
	  print,' Window set to:'
	  print,' xmn, xmx = ', xmn, xmx
	  print,' ymn, ymx = ', ymn, ymx
	endif
 
	;--------  Do a dummy plot to set internal plot scaling parameters ---
	;---  x/ystyle=5 forces exact axes but suppresses axis plot.
	plot,[0,1],/noerase,/nodata,xstyle=5,ystyle=5, chars=csz
 
	return
	end
