;-------------------------------------------------------------
;+
; NAME:
;       ALIGN
; PURPOSE:
;       Vector text justification (positioning).
; CATEGORY:
; CALLING SEQUENCE:
;       align, x,y,txt
; INPUTS:
;       x,y = Reference point.  in
;       txt = Text string.
; KEYWORD PARAMETERS:
;       Keywords:
;         CHARSIZE=csz Character size.
;         AX=ax    Alignment in X (fraction).
;         AY=ax    Alignment in Y (fraction).
;           AX=0, AY=0 is lower left corner of text.
;           AX=1, AY=1 is upper right corner of text.
;         /DEVICE  Means work in device coordinates.
;         /DATA    Means work in data coordinates.
;         /NORMAL  Means work in normalized coordinates.
;         XOUT=xx  Output x position.
;         YOUT=yy  Output x position.
;           xyouts,xx,yy,txt,charsize=csz.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Currently works only for horizontal text.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Apr 4.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro align, x, y, txt, charsize=csz, ax=ax, ay=ay, xout=xx, $
	  yout=yy, device=dev, data=dat, normal=nor, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Vector text justification (positioning).'
	  print,' align, x,y,txt'
	  print,'   x,y = Reference point.  in'
	  print,'   txt = Text string.'
	  print,' Keywords:'
	  print,'   CHARSIZE=csz Character size.'
	  print,'   AX=ax    Alignment in X (fraction).'
	  print,'   AY=ax    Alignment in Y (fraction).'
	  print,'     AX=0, AY=0 is lower left corner of text.'
	  print,'     AX=1, AY=1 is upper right corner of text.'
	  print,'   /DEVICE  Means work in device coordinates.'
	  print,'   /DATA    Means work in data coordinates.'
	  print,'   /NORMAL  Means work in normalized coordinates.'
	  print,'   XOUT=xx  Output x position.'
	  print,'   YOUT=yy  Output x position.'
	  print,'     xyouts,xx,yy,txt,charsize=csz.'
	  print,' Notes: Currently works only for horizontal text.'
	  return
	endif
 
	dy = 0.75*csz*!d.y_ch_size/(!d.y_size+0.)		; Norm dy.
	xyouts,/norm,-10,-10,txt,charsize=csz, width=dx	        ; Norm dx.
 
	if keyword_set(nor) then begin
	  xx = x - ax*dx
	  yy = y - ay*dy
	  return
	endif
 
	if keyword_set(dev) then begin
	  xx = x - ax*dx*!d.x_size
	  yy = y - ay*dy*!d.y_size
	  return
	endif
 
	tmp = convert_coord(x,y,/data,/to_norm)
	tx = tmp(0)
	ty = tmp(1)
	tx2 = tx - ax*dx
	ty2 = ty - ay*dy
	tmp = convert_coord(tx2,ty2,/norm,/to_data)
	xx = tmp(0)
	yy = tmp(1)
 
 	return
	end
