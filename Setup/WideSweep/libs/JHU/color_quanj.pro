;-------------------------------------------------------------
;+
; NAME:
;       COLOR_QUANJ
; PURPOSE:
;       Combines Red, Green, Blue components into a color image.
; CATEGORY:
; CALLING SEQUENCE:
;       c = color_quanj(red, grn, blu, r, g, b)
; INPUTS:
;       red, grn, blu = Red, green, and blue images.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         COLORS=n  Number of colors to have in final image
;           (def=number of available colors).
;         /DITHER   Combined using dithering.
;         /DISPLAY  Display resulting image.
;         /ORDER    Display image with first line at top.
; OUTPUTS:
;       r,g,b = Color table for combined color image.  out
;       c = Resulting color image.                     out
; COMMON BLOCKS:
; NOTES:
;       Notes: This routine uses another color combining method
;         then color_quan, it writes the image to a JPEG file and
;         then reads it back.  This gives better results than
;         color_quan in some cases.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Nov 24
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function color_quanj, red, grn, blu, r, g, b, colors=colors, $
	  dither=dither, display=display, order=order, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Combines Red, Green, Blue components into a color image.'
	  print,' c = color_quanj(red, grn, blu, r, g, b)'
	  print,'   red, grn, blu = Red, green, and blue images.   in'
	  print,'   r,g,b = Color table for combined color image.  out'
	  print,'   c = Resulting color image.                     out'
	  print,' Keywords:'
	  print,'   COLORS=n  Number of colors to have in final image'
	  print,'     (def=number of available colors).'
	  print,'   /DITHER   Combined using dithering.'
	  print,'   /DISPLAY  Display resulting image.'
	  print,'   /ORDER    Display image with first line at top.'
	  print,' Notes: This routine uses another color combining method'
	  print,'   then color_quan, it writes the image to a JPEG file and'
	  print,'   then reads it back.  This gives better results than'
	  print,'   color_quan in some cases.'
	  return,''
	endif
 
	if n_elements(colors) eq 0 then colors=!d.table_size
	if n_elements(dither) eq 0 then dither=0
	if n_elements(order) eq 0 then order=0
 
	;------  Find an unused file  ------------
	n = 0
	repeat begin
	  n = n+1
	  file = 'color_quanj'+strtrim(n,2)+'.tmp'
	  f = findfile(file,count=cnt)
	endrep until cnt eq 0
 
	;------  Set up a 3-d array to contain image  --------
	sz = size(red)
        nx = sz(1)
        ny = sz(2)
        img = bytarr(nx,ny,3)
        img(0,0,0) = red
        img(0,0,1) = grn
        img(0,0,2) = blu
 
	;-------  Write and read back JPEG image  -------
	write_jpeg,file,img,true=3,quality=100
	read_jpeg,file,c,cc,colors=colors,dither=dither,/two_pass
	;-------  Delete file  -------------------------
	openr,lun,file,/delete,/get_lun
	free_lun, lun
 
	;-------  Display  -----------
	if keyword_set(display) then begin
	  if (nx gt 1000) or (ny gt 900) then begin
	    swindow,xs=nx,ys=ny,x_scr=1000<nx,y_scr=900<ny
	  endif else begin
	    window,xs=nx,ys=ny,/free
	  endelse
	  tvlct,cc  ; Load color table.
	  tv,c,order=order
	endif
 
	r = cc(*,0)
	g = cc(*,1)
	b = cc(*,2)
 
	return, c
	end
