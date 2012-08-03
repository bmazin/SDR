;-------------------------------------------------------------
;+
; NAME:
;       POSBOX
; PURPOSE:
;       Test for a box drawn around the screen position, or plot one.
; CATEGORY:
; CALLING SEQUENCE:
;       posbox
; INPUTS:
; KEYWORD PARAMETERS:
;       keyword was given to map_set.  If any inside pixels
;       touch where outline would be then vis is returned as 1.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: main purpose is to see if the screen position has
;         been outlined.  One use is to determine if the /noborder
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Sep 9  (9/9/99)
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro posbox, position=pos, device=dev, visible=vis, plot=plot, $
	  color=clr, x=x, y=y, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Test for a box drawn around the screen position, or plot one.'
	  print,' posbox'
	  print,'   All args are keywords.'
	  print,'   VISIBLE=vis  Is there a box around the screen position?'
	  print,'      0=no, 1=yes.  Always 1 if /PLOT given.'
	  print,'   /PLOT  Plot a box around the screen position.'
	  print,'   COLOR=clr Plot color (def=!p.color).'
	  print,'     If /PLOT not given then the outline color is returned.'
	  print,'   POSITION=pos   Give position to use (else use current).'
	  print,'   /DEVICE   Given position is in device coordinates.
	  print,'   X=x, Y=x  Returned position box in device coordinates'
	  print,'     in form for plot or polyfill.'
	  print,' Notes: main purpose is to see if the screen position has'
	  print,'   been outlined.  One use is to determine if the /noborder'
	  print,'   keyword was given to map_set.  If any inside pixels'
	  print,'   touch where outline would be then vis is returned as 1.'
	  return
	endif
 
	;----  Make sure position is available and in device coodinates  -----
	if n_elements(pos) eq 0 then begin  	; Grab current position.
	  pos = [!x.window(0),!y.window(0),!x.window(1),!y.window(1)]
	  posd = round(pos*[!d.x_size,!d.y_size,!d.x_size,!d.y_size])
	endif else begin			; Given pos.
	  if keyword_set(dev) then begin
	    posd = pos				; Was given pos in pixels.
	  endif else begin
	    posd = round(pos*[!d.x_size,!d.y_size,!d.x_size,!d.y_size])
	  endelse
	endelse
 
	;----  Extract position limits in pixels  ------------
	ix1=posd[0] & iy1=posd[1] & ix2=posd[2] & iy2=posd[3]
	x = [ix1,ix2,ix2,ix1,ix1]		; Closed polygon.
	y = [iy1,iy1,iy2,iy2,iy1]
 
	;----  Plot?  ----------------
	if keyword_set(plot) then begin
	  if n_elements(clr) eq 0 then clr=!p.color
	  plots,/dev,x,y,color=clr
	  vis = 1
	  return
	endif
 
	;----  Try to see if a box around the screen position exists  -----
	;  Box must all be same color, but differ from adjacent pixels
	vis = 0					; Assume no box.
	x1=ix1+1 & x2=ix2-1 & dx=ix2-ix1-1	; Reduce edges by 1 pixel.
	y1=iy1+1 & y2=iy2-1 & dy=iy2-iy1-1
 
	a = tvrd(x1,iy1,dx,1)			; Bottom line.
	b = tvrd(x1,iy1-1,dx,1)			; Just below.
	bclr = a(0)				; Possible box color.
	clr = bclr				; Return outline color.
	w = where(a ne bclr,cnt)		; Any box pixels not bclr?
	if cnt ne 0 then return			; Yes, no outline.
	w = where(a ne b, cnt)			; Same as line above?
	if cnt eq 0 then return			; Yes, no outline.
 
	a = tvrd(x1,iy2,dx,1)			; Top line.
	b = tvrd(x1,iy2+1,dx,1)			; Line above.
	w = where(a ne bclr,cnt)                ; Any box pixels not bclr?
        if cnt ne 0 then return                 ; Yes, no outline.
        w = where(a ne b, cnt)                  ; Same as line above?
        if cnt eq 0 then return                 ; Yes, no outline.
 
	a = tvrd(ix1,y1,1,dy)			; Left line.
	b = tvrd(ix1-1,y1,1,dy)			; Next line out.
        w = where(a ne bclr,cnt)                ; Any box pixels not bclr?
        if cnt ne 0 then return                 ; Yes, no outline.
        w = where(a ne b, cnt)                  ; Same as line above?
        if cnt eq 0 then return                 ; Yes, no outline.
 
	a = tvrd(ix2,y1,1,dy)			; Right line.
	b = tvrd(ix2+1,y1,1,dy)			; Next line out.
        w = where(a ne bclr,cnt)                ; Any box pixels not bclr?
        if cnt ne 0 then return                 ; Yes, no outline.
        w = where(a ne b, cnt)                  ; Same as line above?
        if cnt eq 0 then return                 ; Yes, no outline.
 
	vis = 1					; Looks like an outline.
 
	return
	end
