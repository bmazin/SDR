;-------------------------------------------------------------
;+
; NAME:
;       CPOSPRINT
; PURPOSE:
;       Print a string showing character positions.
; CATEGORY:
; CALLING SEQUENCE:
;       cposprint, s
; INPUTS:
;       s = input string to print.  in
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: prints character positions above string.
;         Invisible characters are translated first,
;         do cposprint,/show to see translation.
; MODIFICATION HISTORY:
;       R. Sterner, 2000 May 31
;       R. Sterner, 2002 May 22 --- Added character translation.
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro cposprint, s, show=show, help=hlp
 
	if ((n_params(0) lt 1) or keyword_set(hlp)) and $
	  (not keyword_set(show)) then begin
	  print,' Print a string showing character positions.'
	  print,' cposprint, s'
	  print,'   s = input string to print.  in'
	  print,' Note: prints character positions above string.'
	  print,'   Invisible characters are translated first,'
	  print,'   do cposprint,/show to see translation.'
	  return
	endif
 
	inchr = [9B]		; List of characters to change.
	outchr = [172B]		; Change to.
	ntran = n_elements(inchr)
 
	;-------  Show translation table  -----------
	if keyword_set(show) then begin
	  print,' '
	  print,' Invisible characters are translated to visible:'
	  for i=0,ntran-1 do begin
	    print,' '+strtrim(fix(inchr(i)),2)+' ---> '+ $
	      strtrim(fix(outchr(i)),2)+' = '+string(outchr(i))
	  endfor
	  print,' '
	  if n_elements(s) eq 0 then return
	endif
 
	;-------  Set up position ruler  ------------
	len = max(strlen(s))
	t0 = '' & t1 = '' & t2 = ''
	for i=0,len-1 do begin
	  a = string(i,form='(I3)')
	  t2 = t2 + strmid(a,0,1)
	  t1 = t1 + strmid(a,1,1)
	  t0 = t0 + strmid(a,2,1)
	endfor
 
	;--------  Display given text string(s)  -------------
	print,t2	
	print,t1
	print,t0
	for i=0,n_elements(s)-1 do begin
	  ss = byte(s(i))
	  for j=0,ntran-1 do begin
	    w = where(ss eq inchr(j),c)
	    if c gt 0 then ss(w)=outchr(j)
	  endfor
	  ss = string(ss)
	  print,ss
	endfor
 
	return
 
	end
