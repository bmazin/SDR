;-------------------------------------------------------------
;+
; NAME:
;       TVRD2
; PURPOSE:
;       Version of tvrd that allows out of bounds.
; CATEGORY:
; CALLING SEQUENCE:
;       img = tvrd2(x,y,dx,dy)
; INPUTS:
;       x,y = lower left corner of screen image to read.  in
;       dx,dy = x and y size to read.                     in
; KEYWORD PARAMETERS:
;       Keywords:
;         TRUE=true Same as TVRD.
;         IMAGE=image Image to use instead of screen.
; OUTPUTS:
;       img = output image.                               out
; COMMON BLOCKS:
; NOTES:
;       Notes: allows x,y to be outside of screen image.
;         Allows dx, dy to extend outside screen image.
;         Values are in pixels.
; MODIFICATION HISTORY:
;       R. Sterner, 1 Oct, 1992
;       R. Sterner, 1999 Oct 05 --- Upgraded for true color.
;       R. Sterner, 2002 Nov 11 --- Allow given image array.
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function tvrd2, x, y, dx, dy, true=true, image=image, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Version of tvrd that allows out of bounds.'
	  print,' img = tvrd2(x,y,dx,dy)'
	  print,'   x,y = lower left corner of screen image to read.  in'
	  print,'   dx,dy = x and y size to read.                     in'
	  print,'   img = output image.                               out'
	  print,' Keywords:'
	  print,'   TRUE=true Same as TVRD.'
	  print,'   IMAGE=image Image to use instead of screen.'
	  print,' Notes: allows x,y to be outside of screen image.'
	  print,'   Allows dx, dy to extend outside screen image.'
	  print,'   Values are in pixels.'
	  return, -1
	endif
 
	if n_elements(true) eq 0 then true=0
 
	;--------  Work from screen  ------------------
	if n_elements(image) eq 0 then begin	; Work from screen.
	  lx = !d.x_size - 1			; Display limits.
	  ly = !d.y_size - 1
	;--------  Work from given image  -------------
	endif else begin			; Work from given image.
	  img_shape, image, nx=nx, ny=ny, true=tr
	  lx = nx-1
	  ly = ny-1
	endelse
 
	;-------  Find inbounds coordinates  -----------
	x1 = x>0<lx			; Keep actual read corner in bounds.
	y1 = y>0<ly
	dxc = dx<(lx-x1+1)<(x+dx)	; Keep actual read size in bounds.
	dyc = dy<(ly-y1+1)<(y+dy)
 
	;-------  Was all outside image  ---------------
	if (dxc le 0) or (dyc le 0) then begin
	  case true of
0:	    return, bytarr(dx, dy)	; 2-d.
1:	    return, bytarr(3,dx,dy)
2:	    return, bytarr(dx,3,dy)
3:	    return, bytarr(dx,dy,3)
	  endcase
	endif
	
	;--------  Work from screen  ------------------
	if n_elements(image) eq 0 then begin	; Work from screen.
	  t = tvrd(x1,y1,dxc,dyc,true=true)	; Read clipped area.
	;--------  Work from given image  -------------
	endif else begin			; Work from given image.
	  t = img_subimg(image,x1,y1,dxc,dyc,true=tr)
	  if tr ne true then t = img_redim(t,true=true)	; Match requested.
	endelse
 
	;-------  Was all inside image  -----------------
        if (dxc eq dx) and (dyc eq dy) then return, t   ; all inside.
 
	;--------  Partly in, partly out  ---------------
	case true of
0:	  z = bytarr(dx, dy)	; 2-d.
1:	  z = bytarr(3,dx,dy)
2:	  z = bytarr(dx,3,dy)
3:	  z = bytarr(dx,dy,3)
	endcase
 
	ix = -(0<x)			; Insertion point.
	iy = -(0<y)
 
	if true eq 0 then begin
	  z(ix,iy) = t
	endif else begin
	  z = img_insimg(z,t,xstart=ix,ystart=iy)
	endelse
 
	return, z
 
;	if true eq 3 then begin
;	  z = bytarr(dx,dy,3)		; Desired output size.
;	  ix = -(0<x)			; Insertion point.
;	  iy = -(0<y)
;	  z(ix,iy,0) = t		; Insert area read from screen.
;	endif else begin
;	  z = bytarr(dx,dy)		; Desired output size.
;	  ix = -(0<x)			; Insertion point.
;	  iy = -(0<y)
;	  z(ix,iy) = t			; Insert area read from screen.
;	endelse
; 
;	return, z
 
	end
