;-------------------------------------------------------------
;+
; NAME:
;       SWINCENTER
; PURPOSE:
;       Center given point in a current scrolling window.
; CATEGORY:
; CALLING SEQUENCE:
;       swincenter, x, y
; INPUTS:
;       x,y = Point to center.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEVICE point is given in device coordinates.
;         /DATA point is given in data coordinates (def).
;         /NORMAL point is given in normalized coordinates.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: viewport of the scrolling window is positioned
;       to center the point if possible.  Ignored if current
;       window is not a scrolling window.
; MODIFICATION HISTORY:
;       R. Sterner. 2005 Sep 06
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro swincenter, x, y, device=dev, data=data, normalized=norm, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Center given point in a current scrolling window.'
	  print,' swincenter, x, y'
	  print,'   x,y = Point to center.   in'
	  print,' Keywords:'
	  print,'   /DEVICE point is given in device coordinates.'
	  print,'   /DATA point is given in data coordinates (def).'
	  print,'   /NORMAL point is given in normalized coordinates.'
	  print,' Notes: viewport of the scrolling window is positioned'
	  print,' to center the point if possible.  Ignored if current'
	  print,' window is not a scrolling window.'
	  return
	endif
 
	;--------------------------------------------------------
	;  Get widget ID of scrolling window draw widget
	;--------------------------------------------------------
	d = swinfo(/draw)	; ID of draw widget in scrolling window.
	if d lt 0 then return	; Not a scrolling window.
 
	;--------------------------------------------------------
	;  Deal with the coordinate system
	;--------------------------------------------------------
	if n_elements(dev)  eq 0 then dev=0
	if n_elements(data) eq 0 then data=0
	if n_elements(norm) eq 0 then norm=0
	if (dev+data+norm) eq 0 then data=1	; Default is data.
 
	;--------------------------------------------------------
	;  Get viewport size
	;--------------------------------------------------------
	v = swinfo(/vis)	; Viewport size in pixels.
	dx = v(0)/2		; Half x size.
	dy = v(1)/2		; Half y size.
 
	;--------------------------------------------------------
	;  Get dev coordinate of given point
	;--------------------------------------------------------
	if dev eq 1 then begin
	  ix = x
	  iy = y
	endif
	if data eq 1 then begin
	  tmp = convert_coord(x,y,/data,/to_dev)
	  ix = tmp(0)
	  iy = tmp(1)
	endif
	if norm eq 1 then begin
	  tmp = convert_coord(x,y,/norm,/to_dev)
	  ix = tmp(0)
	  iy = tmp(1)
	endif
 
	;--------------------------------------------------------
	;  Find and set viewport
	;--------------------------------------------------------
	vx = ix-dx
	vy = iy-dy
	widget_control, d, set_draw_view=[vx,vy]
 
	end
