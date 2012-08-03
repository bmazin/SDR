;-------------------------------------------------------------
;+
; NAME:
;       STRARR2BYT
; PURPOSE:
;       Pack a string array into a byte array
; CATEGORY:
; CALLING SEQUENCE:
;       strarr2byt, tarr, barr
; INPUTS:
;       tarr = text string array.      in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       barr = byte array with text.   out
; COMMON BLOCKS:
; NOTES:
;       Notes: The format of barr is:
;         byte 0: NUM = Number of strings (255 max).
;         byte 1: MAX = Length of longest string (255 max).
;         byte 2: LEN1 = Length of 1st string.
;         byte 3: C1_0 = 1st char of 1st string.
;         byte 4: C1_1 = 2nd char of 1st string.
;         byte 5: C1_2 = 3rd char of 1st string.
;         . . .
;         byte x1 (2+LEN1): C1_last = last char of 1st string.
;         byte x1+1: LEN2 = Length of 2nd string.
;         . . .
;         To last char of last string in tarr.
;         NUM, MAX, LEN1, C1, C2, ..., Clast, LEN2, C1, C2, ...
;       
;         Advantage: saves space, allows storing text arrays of
;         various lengths.  See also byt2strarr, the inverse.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 May 29
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro strarr2byt, tarr, barr, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Pack a string array into a byte array'
	  print,' strarr2byt, tarr, barr'
	  print,'   tarr = text string array.      in'
	  print,'   barr = byte array with text.   out'
	  print,' Notes: The format of barr is:'
	  print,'   byte 0: NUM = Number of strings (255 max).'
	  print,'   byte 1: MAX = Length of longest string (255 max).'
	  print,'   byte 2: LEN1 = Length of 1st string.'
	  print,'   byte 3: C1_0 = 1st char of 1st string.'
	  print,'   byte 4: C1_1 = 2nd char of 1st string.'
	  print,'   byte 5: C1_2 = 3rd char of 1st string.'
	  print,'   . . .'
	  print,'   byte x1 (2+LEN1): C1_last = last char of 1st string.'
	  print,'   byte x1+1: LEN2 = Length of 2nd string.'
	  print,'   . . .'
	  print,'   To last char of last string in tarr.'
	  print,'   NUM, MAX, LEN1, C1, C2, ..., Clast, LEN2, C1, C2, ...'
	  print,' '
	  print,'   Advantage: saves space, allows storing text arrays of'
	  print,'   various lengths.  See also byt2strarr, the inverse.'
	  return
	endif
 
	barr = 0B		; For null string.
	if n_elements(tarr) eq 1 then begin
	  if tarr(0) eq '' then return  ; Null string.
	endif
	b = byte(tarr)		; Convert string array to byte array.
	sz = size(b)		; Want size.
	num = sz(2)		; Number of strings.
	mx = sz(1)		; Length of longest string.
	len = strlen(tarr)	; Lengths of all strings.
 
	barr = bytarr(2+num+total(len))	; Byte array of needed size.
	barr(0) = [num,mx]		; Insert first values.
	in = 2				; Next insertion point.
	for i=0, num-1 do begin		; Loop through all strings.
	  barr(in) = len(i)		; Insert length of ith string.
	  barr(in+1) = byte(tarr(i))	; Insert ith string itself.
	  in = in+1+len(i)		; Update insertion point index.
	endfor
 
	return
	end
