;-------------------------------------------------------------
;+
; NAME:
;       IZOOM
; PURPOSE:
;       Zoom an image and display with labeled axes.
; CATEGORY:
; CALLING SEQUENCE:
;       izoom, x, y, z
; INPUTS:
;       x = 1-d array of x coordinates for every column in z.  in
;       y = 1-d array of y coordinates for every row in z.     in
;       z = 2-d byte scaled image array.                   in
; KEYWORD PARAMETERS:
;       Keywords:
;         XRANGE=xran  X range to zoom. (def=all).
;         YRANGE=xran  Y range to zoom. (def=all).
;           Out of range values are clipped to the valid range.
;         /AXES_ONLY plot axes only.
;         /INTERP means do bilinear interpolation (else pixel rep).
;           No interpolation used for PS plots so /INTERP
;           has no effect.
;         /JS means x is time in Julian Seconds (seconds after
;           2000 Jan 1 0:00).  Gives a date/time axis.
;         OFFSET=off  returned time offset when used with /JS.
;           Same as for jsplot.
;         /CENTER means assume centered pixels.
;         /ANTIALIAS do antialised tick labels (ignored by /JS).
;         Any other keywords are passed on to the plot call used
;         to display the axes (like TITLE, CHARSIZE, POSITION, ...).
;         /NOSCALE do not embed scaling info in image.
;           With scaling info embedded in the image the image x and
;           and y scaling may be set back in effect for the image
;           display window after loading the image or doing a plot
;           in another window by calling set_scale (which applies to
;           current display window, use wset first if needed).
;           plot scaling in image window.
; OUTPUTS:
; COMMON BLOCKS:
;       js_com
; NOTES:
;       Notes: By default entire image is displayed.  XRANGE and
;         YRANGE display a subset of the image.
;         An example use might be: x=array of longitudes,
;         y=array of latitudes, z=array of scaled elevations.
;         May use movbox to return the data ranges of a selected
;         area, then call izoom to zoom it:
;           movbox,ix,iy,dx,dy,xran=xran,yran=yran,/noerase
;           izoom,x,y,z,xran=xran,yran=yran
; MODIFICATION HISTORY:
;       R. Sterner, 3 Dec, 1993
;       R. Sterner, 1994 Feb 16 --- Modified to allow !p.multi.
;       R. Sterner, 1994 Apr 22 --- Added /JS keyword.
;       R. Sterner, 1994 May 17 --- Added OFFSET keyword and js_com.
;       R. Sterner, 1994 Jul 20 --- Fixed to allow reverse ranges.
;       R. Sterner, 1994 Jul 27 --- Made OFFSET 0 for non-time plots.
;       R. Sterner, 1995 Feb 23 --- Fixed minor bug in ranges.
;       R. Sterner, 1996 Dec  2 --- Added keyword /CENTER.
;       R. Sterner, 2000 Apr 18 --- Added keyword /NODATA.
;       R. Sterner, 2000 Apr 20 --- Changed NODATA to /AXES_ONLY.
;       R. Sterner, 2002 Jul 18 --- Added /ANTIALIAS (not /JS yet).
;       R. Sterner, 2006 Jun 28 --- Added /NOSCALE.
;       R. Sterner, 2007 Feb 05 --- Fixed background (for /antialiased).
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	pro izoom, x0, y0, z0, xrange=xran0, yrange=yran0, interp=interp, $
	  js=js, offset=off, center=center, _extra=extra, $
	  axes_only=axes, help=hlp, anti=anti, noscale=noscale, background=back
 
	common js_com, jsoff
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Zoom an image and display with labeled axes.'
	  print,' izoom, x, y, z'
	  print,'   x = 1-d array of x coordinates for every column in z.  in'
	  print,'   y = 1-d array of y coordinates for every row in z.     in'
	  print,'   z = 2-d byte scaled image array.                   in'
	  print,' Keywords:'
	  print,'   XRANGE=xran  X range to zoom. (def=all).'
	  print,'   YRANGE=xran  Y range to zoom. (def=all).'
	  print,'     Out of range values are clipped to the valid range.'
	  print,'   /AXES_ONLY plot axes only.'
	  print,'   /INTERP means do bilinear interpolation (else pixel rep).'
          print,'     No interpolation used for PS plots so /INTERP'
          print,'     has no effect.'
	  print,'   /JS means x is time in Julian Seconds (seconds after'
	  print,'     2000 Jan 1 0:00).  Gives a date/time axis.'
	  print,'   OFFSET=off  returned time offset when used with /JS.'
	  print,'     Same as for jsplot.'
	  print,'   /CENTER means assume centered pixels.'
	  print,'   /ANTIALIAS do antialised tick labels (ignored by /JS).'
	  print,'   Any other keywords are passed on to the plot call used'
	  print,'   to display the axes (like TITLE, CHARSIZE, POSITION, ...).'
	  print,'   /NOSCALE do not embed scaling info in image.'
	  print,'     With scaling info embedded in the image the image x and'
	  print,'     and y scaling may be set back in effect for the image'
	  print,'     display window after loading the image or doing a plot'
	  print,'     in another window by calling set_scale (which applies to'
	  print,'     current display window, use wset first if needed).'
	  print,'     plot scaling in image window.'
	  print,' Notes: By default entire image is displayed.  XRANGE and'
	  print,'   YRANGE display a subset of the image.'
	  print,'   An example use might be: x=array of longitudes,'
	  print,'   y=array of latitudes, z=array of scaled elevations.'
	  print,'   May use movbox to return the data ranges of a selected'
	  print,'   area, then call izoom to zoom it:'
	  print,'     movbox,ix,iy,dx,dy,xran=xran,yran=yran,/noerase'
	  print,'     izoom,x,y,z,xran=xran,yran=yran'
	  return
	endif
 
	;--  Extend arrays to allow for the congrid /minus_one option ---
	nx = n_elements(x0)		; X array size.
	ny = n_elements(y0)		; Y array size.
	dx = (x0(nx-1)-x0(0))/(nx-1.)	; X step.
	dy = (y0(ny-1)-y0(0))/(ny-1.)	; Y step.
	xmn=min(x0) & xmx=max(x0)	; Image x range.
	ymn=min(y0) & ymx=max(y0)	; Image y range.
	;------  Non-centered pixels  --------
	if not keyword_set(center) then begin
	  xmx = xmx + dx
	  ymx = ymx + dy
	endif
 
	;---------  Handle defaults  ------------
	if n_elements(interp) eq 0 then interp=0	; interp default.
	if n_elements(center) eq 0 then center=0	; center default.
	if n_elements(xran0) eq 0 then xran0=[xmn,xmx]	; Default ranges.
	if n_elements(yran0) eq 0 then yran0=[ymn,ymx]
	if xran0(0) lt xran0(1) then begin		; Clip to valid range.
	  xran = [xran0(0)>xmn,xran0(1)<xmx]
	endif else begin
	  xran = [xran0(0)<xmx,xran0(1)>xmn]
	endelse
	if yran0(0) lt yran0(1) then begin		; Clip to valid range.
	  yran = [yran0(0)>ymn,yran0(1)<ymx]
	endif else begin
	  yran = [yran0(0)<ymx,yran0(1)>ymn]
	endelse
 
	;---------  Find image fractions to use  -------
	xfrac = (xran-xmn)/(xmx-xmn)
	yfrac = (yran-ymn)/(ymx-ymn)
 
	noerase_flag = 0
	if keyword_set(axes) then noerase_flag=1
	if n_elements(back) ne 0 then begin
	  erase, back
	  noerase_flag = 1
	endif
 
	;---------  Display image  ------------------
	if keyword_set(js) then begin
	  jsplot,xran,yran,/nodata,/ystyle, yran=yran,$
	    off=off, _extra=extra, noerase=noerase_flag
	  jsoff = off
	endif else begin
	  if keyword_set(anti) then begin
	    aaplot,xran,yran,/nodata,/xstyle,/ystyle,xran=xran,yran=yran,$
	       _extra=extra, noerase=noerase_flag
	  endif else begin
	    plot,xran,yran,/nodata,/xstyle,/ystyle,xran=xran,yran=yran,$
	       _extra=extra, noerase=noerase_flag
	  endelse
	  off = 0.
	  jsoff = off
	endelse
 
	lastplot
 
	if not keyword_set(axes) then begin
	  imgunder, z0, interp=interp, center=center, xfrac=xfrac, yfrac=yfrac
	endif
 
	if keyword_set(js) then begin
	  jsplot,xran,yran,/nodata,/ystyle,/noerase, yran=yran, _extra=extra
	endif else begin
	  if keyword_set(anti) then begin
	    aaplot,xran,yran,/nodata,/xstyle,/ystyle,/noerase,xran=xran, $
	      yran=yran, _extra=extra
	  endif else begin
	    plot,xran,yran,/nodata,/xstyle,/ystyle,/noerase,xran=xran, $
	      yran=yran, _extra=extra
	  endelse
	endelse
 
	nextplot
 
	if not keyword_set(noscale) then put_scale
 
	return
 
	end
