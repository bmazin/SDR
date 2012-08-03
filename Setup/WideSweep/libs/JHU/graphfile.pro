;-------------------------------------------------------------
;+
; NAME:
;       GRAPHFILE
; PURPOSE:
;       List a file on the graphics device.
; CATEGORY:
; CALLING SEQUENCE:
;       graphfile, x, y, txt
; INPUTS:
;       x,y = norm. coord. of upper-left corner of file.  in
;       txt = name of text file or array to list.         in
; KEYWORD PARAMETERS:
;       Keywords:
;         SIZE = text size factor.
;         LSPACE = factor.  Line spacing factor.
;         COLOR=c  text color.
;         /ARRAY means txt is a string array instead of a file name.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 31 Aug, 1989.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro graphfile, x0, y0, file, help=hlp, size=sz, $
	  lspace=lspace, color=color, array=array
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' List a file on the graphics device.'
	  print,' graphfile, x, y, txt'
	  print,'   x,y = norm. coord. of upper-left corner of file.  in'
	  print,'   txt = name of text file or array to list.         in'
	  print,' Keywords:
	  print,'   SIZE = text size factor.'
	  print,'   LSPACE = factor.  Line spacing factor.'
	  print,'   COLOR=c  text color.'
	  print,'   /ARRAY means txt is a string array instead of a file name.'
	  return
	endif
 
	if not n_elements(color) then color = !p.color
	if not n_elements(sz) then sz = 1.
	if not n_elements(lspace) then lspace = 1.
 
	;--- Attempt to get line spacing. ---
	xyouts, -10, -10, 'M', width=dy, color=0, /normal
	dy = sz*2.1*dy*lspace
	y = y0
 
	if not keyword_set(array) then begin
	  txt = getfile(file, error=err)
	  if err ne 0 then goto, err
	endif else begin
	  txt = file
	endelse
 
	ntxt = n_elements(txt)
 
	for i = 0, ntxt-1 do begin
	  xyouts, x0, y, txt(i), size=sz, /normal, color=color
	  y = y - dy
	endfor
 
	goto, done
	
err:	print,'Could not open file'
 
done:	return
	end
 
