;-------------------------------------------------------------
;+
; NAME:
;       IMGUNDER
; PURPOSE:
;       Display image in same area as last plot.
; CATEGORY:
; CALLING SEQUENCE:
;       imgunder, z
; INPUTS:
;       z = scaled byte image to display.  in
;         May be an 8-bit byte array or a 24-bit color image.
; KEYWORD PARAMETERS:
;       Keywords:
;         /INTERP causes bilinear interpolation to be used,
;           otherwise nearest neighbor interpolation is used.
;           No interpolation used for PS plots so /INTERP
;           has no effect.
;         /CENTER means use centered pixels.
;         XFRAC=[xmn,xmx] Fraction of image to use in x (def 0 to 1).
;         YFRAC=[ymn,ymx] Fraction of image to use in y (def 0 to 1).
;         /NODATA means just return without displaying anything.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Do plot,/nodata first to setup plot area,
;         then use imgunder to display image, then repeat
;         plot with data, but with /noerase.
; MODIFICATION HISTORY:
;       R. Sterner, 15 Feb, 1991
;       R. Sterner,  2 Dec, 1993 --- Added /minus_one to congrid call.
;       R. Sterner, 1996 Jun 14 --- Made dy be dy+1 in congrid.
;       R. Sterner, 1996 Dec 2 --- Switched to congrid2 to allow
;       correct interpolation.  Also added /CENTER keyword.
;       R. Sterner, 1997 Mar 5 --- Made PS do 1/2 point pixels (was 1).
;       R. Sterner, 2000 Apr 20 --- Added /NODATA keyword.
;       R. Sterner, 2001 Oct 23 --- Attempting to correct a shift for /int.
;       R. Sterner, 2002 Mar 29 --- Upgraded for 24-bit color.
;       R. Sterner, 2002 Apr 15 --- Rounded plot window coordinates.
;       R. Sterner, 2004 Jun 02 --- Fixed for true color Postscript images.
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro imgunder, z, interp=interp, center=center, $
	  xfrac=xfrac, yfrac=yfrac, nodata=nodata, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Display image in same area as last plot.'
	  print,' imgunder, z'
	  print,'   z = scaled byte image to display.  in'
	  print,'     May be an 8-bit byte array or a 24-bit color image.'
	  print,' Keywords:'
	  print,'   /INTERP causes bilinear interpolation to be used,'
	  print,'     otherwise nearest neighbor interpolation is used.'
	  print,'     No interpolation used for PS plots so /INTERP'
	  print,'     has no effect.'
	  print,'   /CENTER means use centered pixels.'
	  print,'   XFRAC=[xmn,xmx] Fraction of image to use in x (def 0 to 1).'
	  print,'   YFRAC=[ymn,ymx] Fraction of image to use in y (def 0 to 1).'
	  print,'   /NODATA means just return without displaying anything.'
	  print,' Notes: Do plot,/nodata first to setup plot area,'
	  print,'   then use imgunder to display image, then repeat'
	  print,'   plot with data, but with /noerase.'
	  return
	endif
 
	if keyword_set(nodata) then return
 
	img_shape, z, nx=nx, ny=ny, true=tr
	if n_elements(xfrac) eq 0 then xfrac=[0.,1.]
	if n_elements(yfrac) eq 0 then yfrac=[0.,1.]
 
	;---------  Screen display  ------------------------
	if !d.name ne 'PS' then begin
	  xx = round(!x.window*!d.x_size)	; Plot window in dev coords.
	  yy = round(!y.window*!d.y_size)
	  dx = xx(1) - xx(0) + 1		; Plot window size in pixels.
	  dy = yy(1) - yy(0) + 1
	  if keyword_set(center) then begin	; Interpolation indices.
	    x = maken(xfrac(0)*(nx-1),xfrac(1)*(nx-1),dx)+.5
	    y = maken(yfrac(0)*(ny-1),yfrac(1)*(ny-1),dy)+.5
	  endif else begin
	    x = maken(xfrac(0)*nx,xfrac(1)*nx,dx)
	    y = maken(yfrac(0)*ny,yfrac(1)*ny,dy)
	  endelse
	  if not keyword_set(interp) then begin	; NN interpolation.
	    x = fix(x)
	    y = fix(y)
	  endif else begin
	    x = x - 0.5		; Correct for a shift on the /INT option.
	    y = y - 0.5
	  endelse
	  tv,img_interpolate(z,x,y,/grid),xx(0), yy(0), true=tr
	;--------  PostScript display  ----------------
	endif else begin
	  xx = !x.window*!d.x_size/!d.x_px_cm	; Plot window in cm.
	  yy = !y.window*!d.y_size/!d.y_px_cm
	  sx = xx(1) - xx(0)		; X size (cm).
	  sy = yy(1) - yy(0)		; Y size (cm).
	  dx = round(2.*sx/.0352778d0)	; Size in half points.
	  dy = round(2.*sy/.0352778d0)
	  if keyword_set(center) then begin	; Interpolation indices.
	    x = maken(xfrac(0)*(nx-1),xfrac(1)*(nx-1),dx)+.5
	    y = maken(yfrac(0)*(ny-1),yfrac(1)*(ny-1),dy)+.5
	  endif else begin
	    x = maken(xfrac(0)*nx,xfrac(1)*nx,dx)
	    y = maken(yfrac(0)*ny,yfrac(1)*ny,dy)
	  endelse
	  if not keyword_set(interp) then begin	; NN interpolation.
	    x = fix(x)
	    y = fix(y)
	  endif
	  if tr eq 0 then begin		; 8-bit color image.
	    tv,interpolate(z,x,y,/grid),xx(0),yy(0),xsize=sx,ysize=sy,$
	      /cent
	  endif else begin		; 24-bit color image.
	    img_split, z, rr, gg, bb
	    rr = interpolate(rr,x,y,/grid)
	    gg = interpolate(gg,x,y,/grid)
	    bb = interpolate(bb,x,y,/grid)
	    tv,img_merge(rr,gg,bb),xx(0),yy(0),xsize=sx,ysize=sy,$
	      /cent,true=3
	  endelse
	endelse
 
	return
	end
