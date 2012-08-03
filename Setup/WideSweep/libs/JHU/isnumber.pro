;-------------------------------------------------------------
;+
; NAME:
;       ISNUMBER
; PURPOSE:
;       Determine if a text string is a valid number.
; CATEGORY:
; CALLING SEQUENCE:
;       i = isnumber(txt, [x])
; INPUTS:
;       txt = text string to test.                      in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       x = optionaly returned numeric value if valid.  out
;       i = test flag:                                  out
;           0: not a number.
;           1: txt is a long integer.
;           2: txt is a float.
;           -1: first word of txt is a long integer.
;           -2: first word of txt is a float.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  15 Oct, 1986.
;       Johns Hopkins Applied Physics Lab.
;       R. Sterner, 12 Mar, 1990 --- upgraded.
;       Richard Garrett, 14 June, 1992 --- fixed bug in returned float value.
;       R. Sterner, 1999 Nov 30 --- Fixed a bug found by Kristian Kjaer, Denmark
;       R. Sterner, 2006 Sep 07 --- Now works for text arrays.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function isnumber, txt0, x, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Determine if a text string is a valid number.'
	  print,' i = isnumber(txt, [x])'
	  print,'   txt = text string to test.                      in'
	  print,'   x = optionaly returned numeric value if valid.  out'
	  print,'   i = test flag:                                  out'
	  print,'       0: not a number.'
	  print,'       1: txt is a long integer.'
	  print,'       2: txt is a float.'
	  print,'       -1: first word of txt is a long integer.'
	  print,'       -2: first word of txt is a float.'
	  return, -1
	endif
 
	;-----------------------------------------------------
	;  Deal with a text array
	;  Send each element to isnumber.
	;-----------------------------------------------------
	n = n_elements(txt0)
	if n gt 1 then begin
	  typ = bytarr(n)
	  for i=0,n-1 do typ(i)=isnumber(txt0(i))
	  x = txt0
	  if min(typ) eq 0 then return, 0  ; Some non-numeric, so assume all are.
	  out = max(typ)		   ; Highest data type.
	  if out eq 1 then x=long(txt0)	   ; Numeric is long int.
	  if out eq 2 then x=float(txt0)   ; Numeric is float.
	  return,out			   ; Return isnumber code for array.
	endif
 
	;-----------------------------------------------------
	;  Scalar text string
	;-----------------------------------------------------
	txt = strtrim(txt0,2)	; trim blanks.
	x = 0			; define X.
 
	if txt eq '' then return, 0	; null string not a number.
 
	sn = 1
	if nwrds(txt) gt 1 then begin	; get first word if more than one.
	  sn = -1
	  txt = getwrd(txt,0)
	endif
	  
	f_flag = 0			; Floating flag.
	b = byte(txt)			; Convert to byte array.
	if b(0) eq 45 then b=b(1:*)	; Drop leading '-'.   ; Kristian Kjaer
	if b(0) eq 43 then b=b(1:*)	; Drop leading '+'.   ; bug fix.
	w = where(b eq 43, cnt)		; Look for '+'
	if cnt gt 1 then return, 0	; Alow only 1.
	t = delchr(txt,'+')		; Drop it.
	w = where(b eq 45, cnt)		; Look for '-'
	if cnt gt 1 then return, 0	; Allow only 1.
	t = delchr(t,'-')		; Drop it.
	w = where(b eq 46, cnt)		; Look for '.'
	if cnt gt 1 then return, 0	; Allow only 1.
	if cnt eq 1 then f_flag = 1	; If one then floating.
	t = delchr(t,'.')		; Drop it.
	w = where(b eq 101, cnt)	; Look for 'e'
	if cnt gt 1 then return, 0	; Allow only 1.
	if cnt eq 1 then f_flag = 1	; If 1 then assume float.
	t = delchr(t,'e')		; Drop it.
	w = where(b eq 69, cnt)		; Look for 'E'
	if cnt gt 1 then return, 0	; Allow only 1.
	if cnt eq 1 then f_flag = 1	; If 1 then assume float.
	t = delchr(t,'E')		; Drop it.
	w = where(b eq 100, cnt)	; Look for 'd'
	if cnt gt 1 then return, 0	; Allow only 1.
	if cnt eq 1 then f_flag = 1	; If 1 then assume float.
	t = delchr(t,'d')		; Drop it.
	w = where(b eq 68, cnt)		; Look for 'D'
	if cnt gt 1 then return, 0	; Allow only 1.
	if cnt eq 1 then f_flag = 1	; If 1 then assume float.
	t = delchr(t,'D')		; Drop it.
	;-----  Allow only one 'e', 'E', 'd', or 'D'  --------
	if total((b eq 101)+(b eq 69)+(b eq 100)+(b eq 68)) gt 1 then return,0
	b = byte(t)
	;-----  Allow no alphabetic characters  -----------
	if total((b ge 65) and (b le 122)) ne 0 then return, 0
 
	c = strmid(t,0,1)
	if (c lt '0') or (c gt '9') then return, 0  ; First char not a digit.
 
	x = txt + 0.0				    ; Convert to a float.
	if f_flag eq 1 then return, 2*sn	    ; Was floating.
	if x eq long(x) then begin
	  x = long(x)
	  return, sn
	endif else begin
	  return, 2*sn
	endelse
 
	end
