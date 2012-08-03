;-------------------------------------------------------------
;+
; NAME:
;       BASECON
; PURPOSE:
;       Convert an integer number from one base to another.
; CATEGORY:
; CALLING SEQUENCE:
;       out = basecon(in)
; INPUTS:
;       in = input as a text string or numeric value. in
; KEYWORD PARAMETERS:
;       Keywords:
;         FROM=n1    Original number base (def=10).
;           From 2 to 36.
;         TO=n2      Resulting number base (def=10).
;           From 2 to 36.
;         DIGITS=n   Minimum number of digits in output.
;           If result has fewer then 0s are placed on left.
;         GROUP=g    Number of digits to group together (def=all).
;           Spaces will be placed between groups.  Useful for
;           showing bytes or words for example.
;         ERROR=err  error flag:
;           0 = ok
;           1 = input digit not 0-9 or A-Z.
;           2 = FROM base not in the range 2-36.
;           3 = TO base not in the range 2-36.
;           4 = input digit too big for FROM base.
;           5 = input number too big to handle.
;           6 = Data type not supported.
; OUTPUTS:
;       out = converted number as a text string.      out
;         If an error occurs a null string is returned.
; COMMON BLOCKS:
; NOTES:
;       Notes: maximum number base is 36.  Example:
;         out = basecon('1010',from=2,to=16) gives out='A'.
;         May give an array of input values.
;         Can handle negative 16 and 32 bit integers.
;         May group digits in an input string.
; MODIFICATION HISTORY:
;       R. Sterner, 5 Mar, 1993
;       R. Sterner, 30 Sep, 1993 --- Added DIGITS keyword.
;       R. Sterner, 1999 Jun 3 --- Added GROUP keyword.
;       R. Sterner, 2002 Jun 13 --- Extended range by using LONG64.
;       R. Sterner, 2005 Nov 21 --- Supported negative integers.
;       R. Sterner, 2005 Nov 21 --- Allowed spaces in input string.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function basecon, in0, from=from, to=to, error=err, $
	  digits=digits, group=g, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert an integer number from one base to another.'
	  print,' out = basecon(in)'
	  print,'   in = input as a text string or numeric value. in'
 	  print,'   out = converted number as a text string.      out'
	  print,'     If an error occurs a null string is returned.'
 	  print,' Keywords:'
 	  print,'   FROM=n1    Original number base (def=10).'
	  print,'     From 2 to 36.'
	  print,'   TO=n2      Resulting number base (def=10).'
	  print,'     From 2 to 36.'
	  print,'   DIGITS=n   Minimum number of digits in output.'
	  print,'     If result has fewer then 0s are placed on left.'
	  print,'   GROUP=g    Number of digits to group together (def=all).'
	  print,'     Spaces will be placed between groups.  Useful for'
	  print,'     showing bytes or words for example.'
	  print,'   ERROR=err  error flag:'
	  print,'     0 = ok'
	  print,'     1 = input digit not 0-9 or A-Z.'
	  print,'     2 = FROM base not in the range 2-36.'
	  print,'     3 = TO base not in the range 2-36.'
	  print,'     4 = input digit too big for FROM base.'
	  print,'     5 = input number too big to handle.'
	  print,'     6 = Data type not supported.'
	  print,' Notes: maximum number base is 36.  Example:'
	  print,"   out = basecon('1010',from=2,to=16) gives out='A'."
	  print,'   May give an array of input values.'
	  print,'   Can handle negative 16 and 32 bit integers.'
	  print,'   May group digits in an input string.'
	  return,''
	endif
 
	nin = n_elements(in0)
	out = strarr(nin)
 
	for j = 0, nin-1 do begin
 
	in = in0(j)
 
	;-------  Deal with negative values  ------
	typ = datatype(in)
	if typ eq 'BYT' then begin
	  print,' Error in basecon: Byte values not supported.'
	  err = 6
	  return,''
	endif
	if in lt 0 then begin
	  if typ eq 'INT' then in=0U+in
	  if typ eq 'LON' then in=0UL+in
	  if typ eq 'LLO' then begin
	    print,' Error in basecon: Negative Long64 values not supported.'
	    err = 6
	    return,''
	  endif
	endif
 
	;-------  Prepare text string  -----------
	t = strtrim(strupcase(in),2)	; Start with all upper case.
	t = strcompress(t,/rem)		; Allow spaces in input.
	b = byte(t)			; Convert to ascii codes.
	;-------  Invalid error check  ----------
	w = where(b lt 48, cnt)		; Any digit < '0' ?
	if cnt gt 0 then begin
	  err = 1
	  return, ''
	endif
	w = where((b gt 57) and (b lt 65), cnt)	; Digit between '9' and 'A'?
	if cnt gt 0 then begin
	  err = 1
	  return, ''
	endif
	w = where(b gt 90, cnt)		; Any digit > 'Z' ?
	if cnt gt 0 then begin
	  err = 1
	  return, ''
	endif
 
	;--------  Drop alphabetic digits down to range  ----------
	w = where(b gt 57, cnt)			; Any alphabetic digits?
	if cnt gt 0 then b(w) = b(w) - 7	; Yes, fix them.
 
	;--------  Now drop all digits to correct values  -------
	b = b - 48				; Ascii code of '0' is 48.
 
	;-----  Make sure FROM and TO defined and valid  -----------
	if n_elements(from) eq 0 then from = 10		; Default = base 10.
	if (from lt 2) or (from gt 36) then begin
	  err = 2
	  return, ''
	endif
	if n_elements(to) eq 0 then to = 10		; Default = base 10.
	if (to lt 2) or (to gt 36) then begin
	  err = 3
	  return, ''
	endif
 
	;--------  Check if digits valid for specified base  --------
	w = where(b gt (from-1), cnt)
	if cnt gt 0 then begin
	  err = 4
	  return, ''
 	endif
 
	;--------  Convert input number to base 10  --------------
	ten=long64(total(double(b*(long64(from)^reverse(lindgen(n_elements(b)))))))
	if ten lt 0 then begin
	  err = 5
	  return, ''
	endif
 
	;--------  Find digits in base TO  ------------------
	d = [0]				; Digits array seed.
	while ten ge 1 do begin		; Pick off digits in reverse order.
	  d = [d, ten mod to]
	  ten = ten/to
	endwhile
	if n_elements(d) gt 1 then d = reverse(d(1:*))
 
	;--------  Make ascii codes for output number  --------
	w = where(d gt 9, cnt)			; Look for alphabetic digits.
	if cnt gt 0 then d(w) = d(w) + 7	; Handle them.
	d = d + 48				; Convert to ascii codes.
	t = string(byte(d))			; Convert to a string.
 
	;--------  Handle minimum digits  ------------
	if keyword_set(digits) then begin
	  len = strlen(t)
	  add = digits - len			; # 0s needed.
	  if add gt 0 then begin
	    t = string(bytarr(add)+48B)+t	; Add 0s on left.
	  endif
	endif
 
	;--------  Handle grouped digits  ----------
	if n_elements(g) gt 0 then begin
	  if g gt 0 then begin
	    b = byte(t)				; Convert string to byte array.
	    n = n_elements(b)			; Number of digits.
	    rem = n mod g			; Remainder after grouped.
	    if rem ne 0 then b=[bytarr(g-rem)+48B,b]  ; Pad with 0s on left.
	    t = string((byte(string(reform(b,g,n_elements(b)/g))+' '))(0:*))
	  endif
	endif
 
	err = 0
	out(j) = t
 
	endfor ; j
 
	if n_elements(out) eq 1 then out=out(0)
	return, out
 
	end
