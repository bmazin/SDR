;-------------------------------------------------------------
;+
; NAME:
;       POINTID
; PURPOSE:
;       Use the mouse cursor to display an ID for a plotted point.
; CATEGORY:
; CALLING SEQUENCE:
;       pointid, x, y, id
; INPUTS:
;       x,y = Data coordinate arrays for plotted points.   in
;       id = text array identifying the plotted points.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         INDEX=in  Returned index of selected point.  -1 if none.
;         EXIT_CODE=ex   Exit button code.
;         RADIUS=r  Radius in pixels of hotzone around each
;           point (def=10).
;         TOP=top Top line(s) of text
;           (def=Move cursor over a point to identify it).
;         BOTTOM=bot Bottom line(s) of text
;           (def=_____________  Click to exit  ____________)
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: assumes data coordinates are current.  Move the
;       cursor over a point to display the ID text.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Mar 08
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro pointid, x, y, id, radius=rad, index=in, $
	  top=ttxt, bottom=btxt, exit_code=ex,  help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Use the mouse cursor to display an ID for a plotted point.'
	  print,' pointid, x, y, id'
	  print,'   x,y = Data coordinate arrays for plotted points.   in'
	  print,'   id = text array identifying the plotted points.    in'
	  print,' Keywords:'
	  print,'   INDEX=in  Returned index of selected point.  -1 if none.'
	  print,'   EXIT_CODE=ex   Exit button code.'
	  print,'   RADIUS=r  Radius in pixels of hotzone around each'
	  print,'     point (def=10).'
	  print,'   TOP=top Top line(s) of text'
	  print,'     (def=Move cursor over a point to identify it).'
	  print,'   BOTTOM=bot Bottom line(s) of text'
	  print,'     (def=_____________  Click to exit  ____________)'
	  print,' Notes: assumes data coordinates are current.  Move the'
	  print,' cursor over a point to display the ID text.'
	  return
	endif
 
	if n_elements(rad) eq 0 then rad=10.	; Default hotzone radius (pix).
	if n_elements(top) eq 0 then $
	  top='Move cursor over a point to identify it'
	if n_elements(bot) eq 0 then $
          bot='_____________  Click to exit  ____________'
 
	tmp = convert_coord(x,y,/data,/to_dev)	; Convert coordinates to dev.
	ixx = tmp(0,*)
	iyy = tmp(1,*)
 
	xbb,lines=[top, ' ', bot], res=n_elements(top),nid=nid,wid=wid
	nid = nid(0)
 
	!mouse.button = 0
	while !mouse.button eq 0 do begin
	  cursor, ix, iy, /dev, /change
	  dd = (ixx-ix)^2 + (iyy-iy)^2
	  w = where(dd eq min(dd))
	  in = w(0)
	  d = dd(in)
	  if d lt rad then begin
	    widget_control, nid, set_val=id(in)
	  endif else begin
	    widget_control, nid(0), set_val=' '
	    in = -1
	  endelse
	endwhile
	ex = !mouse.button
	widget_control, wid, /dest
	return
 
	end
