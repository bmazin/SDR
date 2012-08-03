;-------------------------------------------------------------
;+
; NAME:
;       SUBIMG
; PURPOSE:
;       From current image select and redisplay a subimage.
; CATEGORY:
; CALLING SEQUENCE:
;       subimg
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         X=x, Y=y returned device coordinates of LL corner.
;         EXIT_CODE=ex  Exit code: 0=ok, 1=abort.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Destroys current window.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Mar 22
;       R. Sterner, 1994 Dec 1 --- Added corner position return.
;       R. Sterner, 1995 Apr 7 --- Switched to box1.
;       R. Sterner, 2000 Jun 29 --- Modified for 24 bit images.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	pro subimg, x=x, y=y, ex=ex, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' From current image select and redisplay a subimage.'
	  print,' subimg'
	  print,'   No args.'
	  print,' Keywords:'
	  print,'   X=x, Y=y returned device coordinates of LL corner.'
	  print,'   EXIT_CODE=ex  Exit code: 0=ok, 1=abort.'
	  print,' Notes: Destroys current window.'
	  return
	endif
 
	box1,/dev,color=-2,x,y,dx,dy,exitcode=ex
	win = !d.window<31
 
	if ex eq 1 then return
	a  = tvrd(x,y,dx,dy,true=3)
 
	sz = size(a)
	window,win,xs=sz(1),ys=sz(2)
	tv,a,true=3
 
	return
	end
