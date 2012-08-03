;-------------------------------------------------------------
;+
; NAME:
;       ROI_INDICES
; PURPOSE:
;       Convert roi_pick region string to indices array.
; CATEGORY:
; CALLING SEQUENCE:
;       in = roi_indices( txt, nx, ny)
; INPUTS:
;       txt = a single text string from roi_pick.  in
;       nx, ny = array dimensions.                 in
; KEYWORD PARAMETERS:
;       Keywords:
;         PX=x, PY=y  Returned polygon points.
; OUTPUTS:
;       in = returned array of indices into array. out
; COMMON BLOCKS:
; NOTES:
;       Note: txt is a single scalar text string containing a
;       region description made by the routine roi_pick.
;       nx and ny give the dimensions of a 2-d array.  This
;       function converts the description of the region to
;       the array indices for that region.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Sep 15
;       R. Sterner, 2004 Sep 16 --- Returned polygon.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function roi_indices, txt, nx, ny, px=x, py=y, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Convert roi_pick region string to indices array.'
	  print,' in = roi_indices( txt, nx, ny)'
	  print,'   txt = a single text string from roi_pick.  in'
	  print,'   nx, ny = array dimensions.                 in'
	  print,'   in = returned array of indices into array. out'
	  print,' Keywords:'
	  print,'   PX=x, PY=y  Returned polygon points.'
	  print,' Note: txt is a single scalar text string containing a'
	  print,' region description made by the routine roi_pick.'
	  print,' nx and ny give the dimensions of a 2-d array.  This'
	  print,' function converts the description of the region to'
	  print,' the array indices for that region.'
	  return,''
	endif
 
	;--------------------------------------------------
	;  Convert txt, text string specifying region, to
	;  a list of numbers, list.
	;--------------------------------------------------
	wordarray,txt,list,del=',',/white
 
	;--------------------------------------------------
	;  Convert numbers describing region to a polygon.
	;--------------------------------------------------
	case list(0)+0 of
1:	  begin				; Box.
	    x1=list(1) & x2=list(2)	; Grab box min and max.
	    y1=list(3) & y2=list(4)
	    x = [x1,x2,x2,x1,x1]	; Form box polygon.
	    y = [y1,y1,y2,y2,y1]
	  end
2:	  begin				; Circle.
	    rad=list(1)			; Grab circle radius and center.
	    ix=list(2) & iy=list(3)
	    polrec, rad, maken(0,2*!pi,100), xx, yy	; Make polygon.
	    x = round(xx + ix)
	    y = round(yy + iy)
	  end
3:	  begin				; Polygon.
	    list = list(1:*)		; Drop region type code.
	    n = n_elements(list)	; Number of values.
	    list = reform(list,2,n/2)	; x1,y1,x2,y2,... Form x,y columns.
	    x = reform(list(0,*))	; Grab x and y of polygon.
	    y = reform(list(1,*))
	    x = [x,x(0)]		; Close.
	    y = [y,y(0)]
	  end
else:	  begin
	    print,' Error in roi_indices: Unkown region type code.  Expecting'
	    print,' 1 (box), 2 (circle), or 3 (poplygon).'
	    print,' Given ',list(0)
	    return,-1
	  end
	endcase
 
	in = polyfillv(x,y,nx,ny)	; Convert polygon for region to indices.
 
	return, in
 
	end
