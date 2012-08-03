;-------------------------------------------------------------
;+
; NAME:
;       RNGBOX
; PURPOSE:
;       Interactively get new plot xrange and yrange.
; CATEGORY:
; CALLING SEQUENCE:
;       rngbox, xrng, yrng
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         EXIT=ex Exit code: 0=ok, else aborted.
; OUTPUTS:
;       xrng = returned xrange array.   out
;       yrng = returned yrange array.   out
; COMMON BLOCKS:
; NOTES:
;       Notes: Use left mouse button to drag open a box.
;       Move box by dragging inside it.  Move an edge or
;       corner by dragging it.  Middle button to exit.
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Feb 21
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
        pro rngbox, xrng, yrng, exit=ex, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Interactively get new plot xrange and yrange.'
	  print,' rngbox, xrng, yrng'
	  print,'   xrng = returned xrange array.   out'
	  print,'   yrng = returned yrange array.   out'
	  print,' Keywords:'
	  print,'   EXIT=ex Exit code: 0=ok, else aborted.'
	  print,' Notes: Use left mouse button to drag open a box.'
	  print,' Move box by dragging inside it.  Move an edge or'
	  print,' corner by dragging it.  Middle button to exit.'
	  return
	endif
 
        print,' '
        print,' Drag open a box on the map.  Move box by dragging inside.'
        print,' May drag a corner or edge.  Click middle button when done.'
        print,' '
 
	xrng = [0.,0.]
	yrng = [0.,0.]
        lim = [0,0,0,0]
 
        box2b, ix1, ix2, iy1, iy2, exit=ex
        if ex eq 1 then return
        tmp = convert_coord([ix1,ix2],[iy1,iy2],/dev,/to_data)
 
	x1 = tmp(0,0)
        x2 = tmp(0,1)
        y1 = tmp(1,0)
        y2 = tmp(1,1)
 
	xrng = [x1,x2]
	yrng = [y1,y2]
 
        end
