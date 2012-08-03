;-------------------------------------------------------------
;+
; NAME:
;       WEBTILE
; PURPOSE:
;       Generate a Netscape web page background tile.
; CATEGORY:
; CALLING SEQUENCE:
;       webtile, x, y
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         INIT=[nx,ny]  Set tile size in pixels.
;         COLOR=clr    Curve color (def=!p.color).
;         FILL=fclr    If given fill polygon x,y.
;         THICK=thk    Curve thickness (def=!p.thick).
;         LINESTY=sty  Curve linestyle (def=!p.linestyle).
;         /NOTES       List notes on making Netscape backgrounds.
; OUTPUTS:
; COMMON BLOCKS:
;       webtile_com
; NOTES:
;       Notes:
;         Point coordinates are pixels into tile from lower
;         left corner.  Curve gets repeated a total of 9 times
;         so that tile edges match.  When all curves have been
;         plotted resulting image may be modified in some way
;         (like topo shading) and then an nx x ny patch read
;         back from anywhere in the plotted area.  This patch
;         may be used as a background tile.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Nov 20
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro webtile, init=init, x, y, color=clr, thick=thk, linestyle=sty, $
	  fill=fclr, notes=notes, help=hlp
 
	common webtile_com, nx, ny
 
	if keyword_set(hlp) then begin
	  print,' Generate a Netscape web page background tile.'
	  print,' webtile, x, y'
	  print,'   x,y = array of points along a curve to plot.'
	  print,' Keywords:'
	  print,'   INIT=[nx,ny]  Set tile size in pixels.'
	  print,'   COLOR=clr    Curve color (def=!p.color).'
	  print,'   FILL=fclr    If given fill polygon x,y.'
	  print,'   THICK=thk    Curve thickness (def=!p.thick).'
	  print,'   LINESTY=sty  Curve linestyle (def=!p.linestyle).'
	  print,'   /NOTES       List notes on making Netscape backgrounds.'
	  print,' Notes:'
	  print,'   Point coordinates are pixels into tile from lower'
	  print,'   left corner.  Curve gets repeated a total of 9 times'
	  print,'   so that tile edges match.  When all curves have been'
	  print,'   plotted resulting image may be modified in some way'
	  print,'   (like topo shading) and then an nx x ny patch read'
	  print,'   back from anywhere in the plotted area.  This patch'
	  print,'   may be used as a background tile.'
	  return
	endif
 
	if keyword_set(notes) then begin
	  print,' Notes on making Netsape backgrounds:'
	  print,'   Any image may be used as a Netscape background (do view'
	  print,'   source for any web page with a background to see how).'
	  print,'   However backgrounds look much better if the image used'
	  print,'   matches itself seamlessly on all sides.  A random image'
	  print,'   with this property may be made using the S1R function'
	  print,'   makez with the keyword /PERIODIC.  For example:'
	  print,'   z = makez(100,100,/per) makes a 100 x 100 pixel random'
	  print,'   image that is periodic on all sides.  To see this in IDL:'
	  print,'      for i=0,20 do tvscl,z,i'
	  print,'   This routine, webtile, allows curves to be plotted with'
	  print,'   similar periodic properties.  The size of the periodic'
	  print,'   region must be specified before plotting with webtile.'
	  print,'   This is done using the INIT=[nx,ny] keyword argument.'
	  print,'   Then just plot any number of curves that pass through'
	  print,'   the region 0-nx, 0-ny.  The routine webtile will replicate'
	  print,'   these curves to form a periodic pattern that will tile'
	  print,'   the background.  Periodic images and periodic curves may'
	  print,'   be combined.  An example using only webtile:'
	  print,'     a=maken(0,360,36) & r=maken(1,1,36) & polrec,r,a,x,y,/deg'
	  print,'     xo=randomu(i,10)*100 & yo=randomu(i,10)*100'
	  print,'     r=randomu(i,10)*50'
	  print,'     webtile,init=[100,100]'
	  print,'     for i=0,9 do webtile,x*r(i)+xo(i),y*r(i)+yo(i)'
	  print,'  Now just read back any 100x100 region of the screen,'
	  print,'  it will be periodic and can be used to tile the background.'
	  return
	endif
 
	if n_elements(fclr) eq 0 then fclr = -1
	if n_elements(clr) eq 0 then clr = !p.color
	if n_elements(thk) eq 0 then thk = !p.thick
	if n_elements(sty) eq 0 then sty = !p.linestyle
 
	if n_elements(init) ne 0 then begin
	  nx = init(0)
	  ny = init(1)
	  if (nx gt 1000) or (ny gt 900) then begin
	    swindow,xs=3*nx,ys=3*ny
	  endif else begin
	    window,xs=3*nx,ys=3*ny
	  endelse
	endif
 
	if n_elements(nx) eq 0 then begin
	  print,' Error in webtile: you must first initialize tile'
	  print,'   by webtile,init=[nx,ny]'
	  return
	endif
 
	if n_params(0) eq 0 then return
 
	if fclr ge 0 then begin
	  for yoff = -ny,ny,ny do begin
	    for xoff = -nx,nx,nx do begin
	      polyfill,/dev,x+nx+xoff,y+ny+yoff,col=fclr
	    endfor ; xoff
	  endfor ; yoff
	endif
 
	for yoff = -ny,ny,ny do begin
	  for xoff = -nx,nx,nx do begin
	    plots,/dev,x+nx+xoff,y+ny+yoff,col=clr, thick=thk, linest=sty
	  endfor ; xoff
	endfor ; yoff
 
	return
	end
