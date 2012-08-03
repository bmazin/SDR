;-------------------------------------------------------------
;+
; NAME:
;       MAP_PIXDEG
; PURPOSE:
;       Return the map scale in pixels/degree at the map center.
; CATEGORY:
; CALLING SEQUENCE:
;       map_pixdeg, pix
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err  Error flag: 0=ok, 1 means no map command.
;         /EASTWEST means return east/west scale, else
;           north/south scale is returned. The two scales
;           should be very close if /ISO was used on the
;           map_set (or map_set2) command.
; OUTPUTS:
;       pix = Map scale at center in pixels/degree.  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jan 21
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro map_pixdeg, pix, error=err, eastwest=eastwest, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return the map scale in pixels/degree at the map center.'
	  print,' map_pixdeg, pix'
	  print,'   pix = Map scale at center in pixels/degree.  out'
	  print,' Keywords:'
	  print,'   ERROR=err  Error flag: 0=ok, 1 means no map command.'
	  print,'   /EASTWEST means return east/west scale, else'
	  print,'     north/south scale is returned. The two scales'
	  print,'     should be very close if /ISO was used on the'
	  print,'     map_set (or map_set2) command.'
	  return
	endif
 
	;------  Make sure last plot command was a map_set  ----------
	if !x.type ne 3 then begin
 	  print,' Error in map_pixdeg: Map scaling not available.'
	  print,'   Must call this routine after map_set2 and before'
	  print,'   any other routine (like plot) resets scale.'
	  err = 1
	  return
	endif
 
	;-----  Central map scale (pixels/degree)  -----------
	x = fix(!d.x_size*!x.window)
	y = fix(!d.y_size*!y.window)
	ix1=x(0) & ix2=x(1)
	iy1=y(0) & iy2=y(1)
	ixmd=(ix1+ix2)/2. & iymd=(iy1+iy2)/2.
	if keyword_set(eastwest) then begin
	  ixa=ixmd-10 & ixb=ixmd+10
	  iya=iymd    & iyb=iymd
	endif else begin
	  ixa=ixmd    & ixb=ixmd
	  iya=iymd-10 & iyb=iymd+10
	endelse
 
	tmp=convert_coord([ixa,ixb],[iya,iyb],/dev,/to_data)
	x=tmp(0,*) & y=tmp(1,*)
	d = sphdist(x(0),y(0),x(1),y(1),/deg)
	pix = 20/d
 
	err = 0
 
	return
	end
