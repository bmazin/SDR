;-------------------------------------------------------------
;+
; NAME:
;       PLOTSH
; PURPOSE:
;       Plot curves with a drop shadow.
; CATEGORY:
; CALLING SEQUENCE:
;       plotsh, x, y
; INPUTS:
;       x,y = Curve x and y, data coordinates only.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=clr  Curve color (def=!p.color).
;         SCOLOR=sclr Drop shadow color (def=!d.background).
;         XOFF=xoff  Shadow x offset in pixels (def=1).
;         YOFF=yoff  Shadow y offset in pixels (def=-1).
;         Other PLOTS keywords allowed.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Feb 01
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro plotsh, x, y, color=clr,scolor=sclr,xoff=xoff,yoff=yoff, $
	  device=dev, normalized=norm, _extra=extra, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Plot curves with a drop shadow.'
	  print,' plotsh, x, y'
 	  print,'   x,y = Curve x and y, data coordinates only.  in'
	  print,' Keywords:'
	  print,'   COLOR=clr  Curve color (def=!p.color).'
	  print,'   SCOLOR=sclr Drop shadow color (def=!d.background).'
	  print,'   XOFF=xoff  Shadow x offset in pixels (def=1).'
	  print,'   YOFF=yoff  Shadow y offset in pixels (def=-1).'
	  print,'   Other PLOTS keywords allowed.'
	  return
	endif
 
	;-------  Defaults  ------------
	if n_elements(clr) eq 0 then clr=!p.color
	if n_elements(sclr) eq 0 then sclr=!p.background
	if n_elements(xoff) eq 0 then xoff=1
	if n_elements(yoff) eq 0 then yoff=-1
 
	;--------  Work in device coordinates  ---------
	if keyword_set(dev) then begin
	  ix = x
	  iy = y
	endif else begin
	  if keyword_set(norm) then begin
	    t = convert_coord(x,y,/norm,/to_dev)
	    ix = t(0,*)
	    iy = t(1,*)
	  endif else begin
	    t = convert_coord(x,y,/data,/to_dev)
	    ix = t(0,*)
	    iy = t(1,*)
	  endelse
	endelse
 
	;--------  Plot shadow  ---------
	plots,/dev,ix+xoff,iy+yoff,color=sclr,_extra=extra
 
	;--------  Plot curve  ---------
	plots,/dev,ix,iy,color=clr,_extra=extra
 
	end
