;-------------------------------------------------------------
;+
; NAME:
;       LISTRUNS
; PURPOSE:
;       Make a list of runs of consecutive integers.
; CATEGORY:
; CALLING SEQUENCE:
;       listruns, w, txt
; INPUTS:
;       w = array of integers (indices).           in
; KEYWORD PARAMETERS:
;       Keywords:
;         /list means display list on screen.
;         WIDTH=wd set string array width (def=40).
; OUTPUTS:
;       txt = text string array with runs listed.  out
; COMMON BLOCKS:
; NOTES:
;       Notes:
;         Each run is listed in the form b:e:s where b is the
;         run beginning value, e is the run ending value,
;         and s is the run step size.  If s = 1 it is not listed.
;         Isolated indices are listed by themselves.
;	  Inverse of CONVERT_IND.
; MODIFICATION HISTORY:
;       R. Sterner, 15 Jul, 1991
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro listruns, a, txt, list=list, width=width, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Make a list of runs of consecutive integers.'
	  print,' listruns, w, txt'
	  print,'   w = array of integers (indices).           in'
	  print,'   txt = text string array with runs listed.  out'
	  print,' Keywords:'
	  print,'   /list means display list on screen.'
	  print,'   WIDTH=wd set string array width (def=40).'
	  print,' Notes:'
	  print,'   Each run is listed in the form b:e:s where b is the'
	  print,'   run beginning value, e is the run ending value,'
	  print,'   and s is the run step size.  If s = 1 it is not listed.'
	  print,'   Isolated indices are listed by themselves.'
	  print,'   Inverse of CONVERT_IND.PRO.'
	  return
	endif
 
	if n_elements(width) eq 0 then width = 40  ; Set default text width.
 
	txt = ['']			; Start output text array.
	row = ''			; Start a row of text.
 
        if (size(a))(0) le 0 then begin
          print,' Error in listruns: argument must be an array.
          return
        endif
 
	;-------  Find differences  ------
	d = shift(a,-1) - a
	dd = shift(d,-1) - d
	w = where(dd eq 0)
	i = 0
	lst = n_elements(dd)-1
 
loop:	if dd(i) eq 0 then begin		; Found a 0 in dd.
	  s = a(i)				; Set range start.
	  e = s					; Set default range end.
	  d = 1					; Default step.
loop2:	  i = i + 1				; Go to next.
	  if i gt lst then goto, skip		; Done?
	  if dd(i) eq 0 then goto, loop2	; Another 0?
	  i = i + 1				; Go one more.
	  e = a(i)				; Set range end.
	  d = a(i) - a(i-1)			; Set range step.
	endif else begin
	  s = a(i)				; Range start.
	  e = s					; Set default range end.
	  d = 1					; Default step.
	endelse
skip:
	add = ''			; Start range string.
	if row ne '' then add = ' '	; Adding to existing text.
	add = add+strtrim(s,2)	; List first index.
	if e ne s then add = add+':'+strtrim(e,2)	; List last index.
	if d ne 1 then add = add+':'+strtrim(d,2)	; Step.
	if i lt lst then add = add+','	; More to come, add comma.
	if strlen(row+add) gt width then begin
	  txt = [txt,row]
	  row = ''
	  add = strmid(add,1,999)
	endif
	row = row + add
	i = i + 1
	if i le lst then goto, loop
 
	if row ne '' then txt = [txt, row]
	txt = txt(1:*)
 
	if keyword_set(list) then begin
	  for i = 0, n_elements(txt)-1 do print,txt(i)
	endif
 
	return
	end
