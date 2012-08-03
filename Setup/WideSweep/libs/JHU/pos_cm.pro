;-------------------------------------------------------------
;+
; NAME:
;       POS_CM
; PURPOSE:
;       Convert keyword POSITION for PLOT from cm to norm. coords.
; CATEGORY:
; CALLING SEQUENCE:
;       out = pos_cm(in)
; INPUTS:
;       in = the array [x1,y1,x2,y2]              in
;          where (x1,y1) = lower left corner,
;          and (x2,y2) = upper right corner of plot area in cm.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = normalized coordinates.             out
; COMMON BLOCKS:
; NOTES:
;       Note: if used to convert the position array before call
;         to plot, be sure plot device is set first.
;         For PostScript plots call psinit first.
; MODIFICATION HISTORY:
;       R. Sterner, 22 Sep, 1989
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function pos_cm, posin, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert keyword POSITION for PLOT from cm to norm. coords.'
	  print,' out = pos_cm(in)'
	  print,'   in = the array [x1,y1,x2,y2]              in'
	  print,'      where (x1,y1) = lower left corner,
	  print,'      and (x2,y2) = upper right corner of plot area in cm.'
	  print,'   out = normalized coordinates.             out'
	  print,' Note: if used to convert the position array before call'
	  print,'   to plot, be sure plot device is set first.'
	  print,'   For PostScript plots call psinit first.'
	  return, -1
	endif
 
	fx = !d.x_px_cm/!d.x_size
	fy = !d.y_px_cm/!d.y_size
	return, posin*[fx,fy,fx,fy]
	end
