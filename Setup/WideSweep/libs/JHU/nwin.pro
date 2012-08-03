;-------------------------------------------------------------
;+
; NAME:
;       NWIN
; PURPOSE:
;       Convert from normalized window coordinates.
; CATEGORY:
; CALLING SEQUENCE:
;       nwin, x, y, x2, y2
; INPUTS:
;       x,y = normalized window coordinates of a point.     in
; KEYWORD PARAMETERS:
;       Keywords:
;         /TO_DATA  converts to data coordinates (def).
;         /TO_DEVICE  converts to device coordinates.
;         /TO_NORMALIZED  converts to normalized coordinates.
; OUTPUTS:
;       x2,y2 = same point in specified coordinate system.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: The plot window is the area defined by the axes.
;         Normalized window coordinates are defined here to be
;         linear from (0,0) at the lower left corner of the plot
;         window, and (1,1) at the upper right.
;         Useful for plot window related items such as legends.
;         Normalized coordinates are really normalized device
;         coordinates.  Normalized window coordinates are missing
;         from IDL's list of coordinate systems.
; MODIFICATION HISTORY:
;       R. Sterner, 30 Jul, 1993
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro nwin, x, y, x2, y2, to_data=data, to_normalized=norm, $
	  to_device=dev, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Convert from normalized window coordinates.'
	  print,' nwin, x, y, x2, y2'
	  print,'   x,y = normalized window coordinates of a point.     in'
	  print,'   x2,y2 = same point in specified coordinate system.  out'
	  print,' Keywords:'
	  print,'   /TO_DATA  converts to data coordinates (def).'
	  print,'   /TO_DEVICE  converts to device coordinates.'
	  print,'   /TO_NORMALIZED  converts to normalized coordinates.'
	  print,' Notes: The plot window is the area defined by the axes.'
	  print,'   Normalized window coordinates are defined here to be'
	  print,'   linear from (0,0) at the lower left corner of the plot'
	  print,'   window, and (1,1) at the upper right.'
	  print,'   Useful for plot window related items such as legends.'
	  print,'   Normalized coordinates are really normalized device'
	  print,"   coordinates.  Normalized window coordinates are missing"
	  print,"   from IDL's list of coordinate systems."
	  return
	endif
 
	dx = !x.crange(1) - !x.crange(0)	; Plot window range.
	dy = !y.crange(1) - !y.crange(0)
 
	;-------  To Data (def)  --------
	x2 = !x.crange(0) + x*dx		; Data coordinates.
	y2 = !y.crange(0) + y*dy
	if !x.type eq 1 then x2 = 10^x2		; Handle log axes.
	if !y.type eq 1 then y2 = 10^y2
 
	;-------  From data to normalized  ------
	if keyword_set(norm) then begin
	  aa = convert_coord([x2],[y2],/data,/to_norm)
	  x2 = aa(0)  & y2 = aa(1)
	endif
 
	;-------  From data to device  ------
	if keyword_set(dev) then begin
	  aa = convert_coord([x2],[y2],/data,/to_dev)
	  x2 = aa(0)  & y2 = aa(1)
	endif
 
	return
	end
