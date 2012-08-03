;-------------------------------------------------------------
;+
; NAME:
;       TEXTPOS
; PURPOSE:
;       Find size and angle of text string given points at each end.
; CATEGORY:
; CALLING SEQUENCE:
;       textpos, txt, p1, p2, ix,iy,sz,ang
; INPUTS:
;       txt = Desired text string.                       in
;       p1 = [x1,y1] = text starting point.              in
;       p2 = [x2,y2] = text end point.                   in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DATA input points in data coordinates (default).
;         /DEVICE input points in device coordinates.
;         /NORMAL input points in normalized coordinates.
;         ALIGNMENT=jst  Desired text alignment (def=0.).
; OUTPUTS:
;       ix,iy = Returned device coordinates of text.     out
;       sz = Returned charsize for text.                 out
;       ang = Returned angle of text.                    out
; COMMON BLOCKS:
; NOTES:
;       Notes: If p1 is desired text string starting point then
;         xyouts may use the same coordinate system as p1.
;         But if ALIGNMENT is not 0 then use the returned device
;         coordinates, ix,iy.  Text is not plotted, only the
;         position, size, and angle is determined.  Use xyouts
;         to actually plot the text and remember to use the same
;         value for the alignment parameter.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Mar 3
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro textpos, txt, p1, p2, ix,iy,sz,ang, alignment=align, $
	  data=dat0, device=dev0, normal=nrm0, help=hlp
 
	if (n_params(0) lt 7) or keyword_set(hlp) then begin
	  print,' Find size and angle of text string given points at each end.'
	  print,' textpos, txt, p1, p2, ix,iy,sz,ang'
	  print,'   txt = Desired text string.                       in'
	  print,'   p1 = [x1,y1] = text starting point.              in'
	  print,'   p2 = [x2,y2] = text end point.                   in'
	  print,'   ix,iy = Returned device coordinates of text.     out'
	  print,'   sz = Returned charsize for text.                 out'
	  print,'   ang = Returned angle of text.                    out'
	  print,' Keywords:'
	  print,'   /DATA input points in data coordinates (default).'
	  print,'   /DEVICE input points in device coordinates.'
	  print,'   /NORMAL input points in normalized coordinates.'
	  print,'   ALIGNMENT=jst  Desired text alignment (def=0.).'
	  print,' Notes: If p1 is desired text string starting point then'
 	  print,'   xyouts may use the same coordinate system as p1.'
 	  print,'   But if ALIGNMENT is not 0 then use the returned device'
	  print,'   coordinates, ix,iy.  Text is not plotted, only the'
	  print,'   position, size, and angle is determined.  Use xyouts'
	  print,'   to actually plot the text and remember to use the same'
 	  print,'   value for the alignment parameter.'
	  return
	endif
 
        ;--------  Determine coordinate system  ---------------
        dat = keyword_set(dat0)
        dev = keyword_set(dev0)
        nrm = keyword_set(nrm0)
        if dat+dev+nrm gt 1 then begin
          print,' Error in lini: set only one of /DATA, /DEVICE, or /NORMAL.'
          return
        endif
        if dat eq 0 then dat=1-(dev>nrm)        ; Def is /data.
 
	;-------  Desired endpoints  --------------------------
	if n_elements(p1) ne 2 then begin
	  print,' Error in textpos: Must give text starting point as'
	  print,'   a 2 element array [x1,y1].'
	  return
	endif
	if n_elements(p2) ne 2 then begin
	  print,' Error in textpos: Must give text ending point as'
	  print,'   a 2 element array [x2,y2].'
	  return
	endif
	x1=p1(0) & y1=p1(1)
	x2=p2(0) & y2=p2(1)
 
	;---------  Convert to device coordinates  --------------
	tmp = convert_coord([x1,x2],[y1,y2],dat=dat,dev=dev,norm=nrm,/to_dev)
        ix=tmp(0,*) & iy=tmp(1,*)
	ix1=ix(0) & ix2=ix(1)
	iy1=iy(0) & iy2=iy(1)
	dx=ix2-ix1 & dy=iy2-iy1
 
	;------  Desired size and angle  -----------
        recpol,dx,dy,szpix1,ang,/deg		; Text angle.
	xyouts,100000,100000,/dev,txt,width=wid	; Get normalize text length.
	szpix2 = wid*!d.x_size			; Text size for charsize=1.
	sz = szpix1/szpix2			; Ratio gives charsize.
 
	;------  Deal with text alignment  ----------
	if n_elements(align) eq 0 then align=0.	; Default alignment.
	ix = ix1 + align*dx
	iy = iy1 + align*dy
	
	return
	end
