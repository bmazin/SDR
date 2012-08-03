;-------------------------------------------------------------
;+
; NAME:
;       COMPLEXVIEW
; PURPOSE:
;       View a subarea of a complex image as a vector field.
; CATEGORY:
; CALLING SEQUENCE:
;       complexview, z
; INPUTS:
;       z = complex array.      in
; KEYWORD PARAMETERS:
;       Keywords:
;         NX=nx, NY=nx  Option subarea size (def=50 x 30).
;         /KEEP to keep vector plot box on exit.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: It is assumed that the complex image is being
;       displayed in the current window.  This may be any
;       property of the image, like magnitude, phase, power, ...
;       and must be in a window the same size as the complex array.
;         Drag box around in displayed complex image window.
;       Click middle mouse button to exit.  View area may be changed
;       also after clicking middle button.  Click continue after
;       changing view area.  Can right click on vector plot window
;       and set to Always on top.
;         Axis labels apply to the lower left corner of the complex
;       pixels.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Mar 01
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro complexview, z, nx=nx, ny=ny, keep=keep, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' View a subarea of a complex image as a vector field.'
	  print,' complexview, z'
	  print,'   z = complex array.      in'
	  print,' Keywords:'
	  print,'   NX=nx, NY=nx  Option subarea size (def=50 x 30).'
	  print,'   /KEEP to keep vector plot box on exit.'
	  print,' Notes: It is assumed that the complex image is being'
	  print,' displayed in the current window.  This may be any'
	  print,' property of the image, like magnitude, phase, power, ...'
	  print,' and must be in a window the same size as the complex array.'
	  print,'   Drag box around in displayed complex image window.'
	  print,' Click middle mouse button to exit.  View area may be changed'
	  print,' also after clicking middle button.  Click continue after'
	  print,' changing view area.  Can right click on vector plot window'
	  print,' and set to Always on top.'
	  print,'   Axis labels apply to the lower left corner of the complex'
	  print,' pixels.'
	  return
	endif
 
	;------  Subarea size  --------------
	if n_elements(nx) eq 0 then nx=50
	if n_elements(ny) eq 0 then ny=30
 
	;------  Initialize  ----------------
	if !d.window lt 0 then begin
	  print,' Error in complexview: No display window.'
	  print,'   Must display the complex image in a window of the same'
	  print,'   size as the array.'
	  return
	endif
	flag = swinfo(!d.window,/exists)	; Current window an swindow?
	;-------  Find lower left corner of starting box  -----
	if flag eq 0 then begin			; Normal window.
	  bx1 = !d.x_size/2
	  by1 = !d.y_size/2
	endif else begin			; Swindow.
	  vis = swinfo(!d.window,/vis)		; Size of visible area.
	  if max(vis) eq 0 then begin		; Was ordinary window.
	    bx1 = !d.x_size/2
	    by1 = !d.y_size/2
	  endif else begin			; Really was an swindow.
	    vw = swinfo(!d.window,/view)	; Get lower left point.
	    bx1 = vw(0) + vis(0)/2
	    by1 = vw(1) + vis(1)/2
	  endelse
	endelse
	bx2 = bx1 + nx - 1
	by2 = by1 + ny - 1
 
	plexview, init=z, nx=nx, ny=ny, keep=keep
 
	;------  Interactive box  -----------
	wshow
	box2b,change='plexview',bx1,bx2,by1,by2,/lock,ch_flag=2
 
	;-------  Cleanup  ----------
	plexview, /terminate
 
	end
