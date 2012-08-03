;-------------------------------------------------------------
;+
; NAME:
;       POLYFILLTR
; PURPOSE:
;       Polyfill on current image with a transparent color.
; CATEGORY:
; CALLING SEQUENCE:
;       polyfilltr, x, y, pen
; INPUTS:
;       x,y = polygon vertices.  in
;       pen = optional pen code (0=pen up, 1=pen down).
;         Pen code needed if x,y contain multiple polygons.
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEVICE Polygon is in device coordinates (def).
;         /DATA Polygon is in data coordinates.
;         /NORMAL Polygon is in normalized coordinates.
;         COLOR=clr Polygon color (24-bit).
;         WT=wt  Weight (def=1=full color, 0=no color).
;         SMOOTH=sm Smoothing size for softing edges (def=none).
;         /ILLUMINATE Means illuminate polygon area instead of
;           treating as a colored filter.
;         /INVERSE uses the outsides of the polygons.
;         FILL=fclr Solid fill color (def=none).
;         OCOLOR=oclr Polygon outline color (def=none).
;         THICK=thk Polygon outline thickness (def=!p.thick).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Transparent polygon done first, then any solid fill,
;         then any outline.  Could do a smoothed transparent fill
;         with a solid fill and an outline to make a glow around
;         the polygon. Extra keywords may be sent to polyfillp.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Oct 08
;       R. Sterner, 2004 Oct 14 --- Added /ILLUMINATE option.
;       R. Sterner, 2004 Oct 14 --- Added /INVERSE, outline and fill.
;       R. Sterner, 2004 Oct 25 --- Added _extra=extra to allow noclip=0.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro polyfilltr, x, y, pen, data=dat, device=dev, normal=nor, $
	  color=clr, smooth=sm, wt=wt, illuminate=ill, inverse=inverse, $
	  ocolor=oclr, thick=thk, fill=fclr, _extra=extra, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Polyfill on current image with a transparent color.'
	  print,' polyfilltr, x, y, pen'
	  print,'   x,y = polygon vertices.  in'
	  print,'   pen = optional pen code (0=pen up, 1=pen down).'
	  print,'     Pen code needed if x,y contain multiple polygons.'
	  print,' Keywords:'
	  print,'   /DEVICE Polygon is in device coordinates (def).'
	  print,'   /DATA Polygon is in data coordinates.'
	  print,'   /NORMAL Polygon is in normalized coordinates.'
	  print,'   COLOR=clr Polygon color (24-bit).'
	  print,'   WT=wt  Weight (def=1=full color, 0=no color).'
	  print,'   SMOOTH=sm Smoothing size for softing edges (def=none).'
	  print,'   /ILLUMINATE Means illuminate polygon area instead of'
	  print,'     treating as a colored filter.'
	  print,'   /INVERSE uses the outsides of the polygons.'
	  print,'   FILL=fclr Solid fill color (def=none).'
	  print,'   OCOLOR=oclr Polygon outline color (def=none).'
	  print,'   THICK=thk Polygon outline thickness (def=!p.thick).'
	  print,' Notes: Transparent polygon done first, then any solid fill,'
	  print,'   then any outline.  Could do a smoothed transparent fill'
	  print,'   with a solid fill and an outline to make a glow around'
	  print,'   the polygon. Extra keywords may be sent to polyfillp.'
	  return
	endif
 
	;-----  Force to device coordinates  -----
	ix = x
	iy = y
	if keyword_set(dat) then begin
	  tmp = convert_coord(x,y,/data,/to_dev)
	  ix = tmp(0,*)
	  iy = tmp(1,*)
	endif
	if keyword_set(nor) then begin
	  tmp = convert_coord(x,y,/norm,/to_dev)
	  ix = tmp(0,*)
	  iy = tmp(1,*)
	endif
 
	;-----  Grab current image  --------
	base = tvrd(tr=3)
	img_shape, base, nx=nx, ny=ny
 
	;-----  Make colored filter  -------
	window, /free, xs=nx, ys=ny, /pixmap
	if keyword_set(ill) then erase else erase, -1
	polyfillp, ix, iy, pen, /dev, color=clr, _extra=extra 
 
	;-----  Inverse  ----------
	if keyword_set(inverse) then begin
	  if keyword_set(ill) then begin	; Illuminate (additive)
	    for i=1, 3 do begin			; Channel by channel.
	      a = 255-tvrd(chan=i)		; Read channel.
	      tv,chan=i,a-min(a)		; Flip brightness in channel.
	    endfor
	  endif else begin			; Filter (subtractive).
	    for i=1, 3 do begin			; Channel by channel.
	      a = tvrd(chan=i)			; Read channel.
	      tv,chan=i,255-a+min(a)		; Flip brightness in channel.
	    endfor
	  endelse
	endif
 
	;-----  Read filter  ----------
	f = tvrd(tr=3)
	wdelete
 
	;-----  Smooth  ---------
	if n_elements(sm) ne 0 then f = img_smooth2(f, sm)
 
	;-----  Apply filter and display  ------
	if keyword_set(ill) then begin
	  tv, img_illuminate(base, f, wt=wt), tr=3
	endif else begin
	  tv, img_cfilter(base, f, wt=wt), tr=3
	endelse
 
	;-----  Any solid fill  ------------
	if n_elements(fclr) gt 0 then begin
	  polyfillp, ix, iy, pen, /dev, color=fclr, _extra=extra
	endif
 
	;-----  Outline if any  ------------
	if n_elements(oclr) gt 0 then begin
	  if n_elements(thk) eq 0 then thk=!p.thick
	  plotp, ix, iy, pen, /dev, color=oclr, thick=thk, _extra=extra
	endif
 
	end
