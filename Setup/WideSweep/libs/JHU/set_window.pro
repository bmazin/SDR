;-------------------------------------------------------------
;+
; NAME:
;       SET_WINDOW
; PURPOSE:
;       Set data window.
; CATEGORY:
; CALLING SEQUENCE:
;       set_window, x0, x1, y0, y1
; INPUTS:
;       x0,x1 = x data min and max.    in
;       y0,y1 = y data min and max.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         NXRANGE = [nx0, nx1]: window x pos. in norm. coord.
;         NYRANGE = [ny0, ny1]: window y pos. in norm. coord.
;         Defaults for both are [0,1]
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: x0 maps to nx0, x1 maps to nx1, y0 maps to ny0, y1 maps to ny1.
;         For oplot and plots only.  plot sets its own window.
; MODIFICATION HISTORY:
;       R. Sterner, 10 Sep, 1989.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro set_window, x0, x1, y0, y1, nxrange=xrng, nyrange=yrng, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin	
	  print,' Set data window.'
	  print,' set_window, x0, x1, y0, y1'
	  print,'   x0,x1 = x data min and max.    in'
	  print,'   y0,y1 = y data min and max.    in'
	  print,' Keywords:'
	  print,'   NXRANGE = [nx0, nx1]: window x pos. in norm. coord.'
	  print,'   NYRANGE = [ny0, ny1]: window y pos. in norm. coord.'
	  print,'   Defaults for both are [0,1]'
	  print,' Note: x0 maps to nx0, x1 maps to nx1, y0 maps to ny0, '+$
	    'y1 maps to ny1.'
	  print,'   For oplot and plots only.  plot sets its own window.'
	  return
	endif
 
	if n_elements(xrng) eq 0 then xrng = [0., 1.]
	if n_elements(yrng) eq 0 then yrng = [0., 1.]
	if not isarray(xrng) then begin
	  print,' nxrange keyword must be an array: nxrange=[min_x,'+$
	    ' max_x] in normalized coord.'
	  return
	endif
	if not isarray(yrng) then begin
	  print,' nyrange keyword must be an array: nyrange=[min_y, '+$
	    'max_y] in normalized coord.'
	  return
	endif
 
	nx0 = xrng(0) & nx1 = xrng(1) & ny0 = yrng(0) & ny1 = yrng(1)
 
	!x.style = 1
	!y.style = 1
	!x.range = [x0, x1]
	!y.range = [y0, y1]
	!x.s = [x1*nx0-x0*nx1, nx1-nx0]/(x1-x0)
	!y.s = [y1*ny0-y0*ny1, ny1-ny0]/(y1-y0)
 
	return
	end
