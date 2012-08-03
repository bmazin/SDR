;-------------------------------------------------------------
;+
; NAME:
;       BYT2STRARR
; PURPOSE:
;       Unpack a string array from a byte array
; CATEGORY:
; CALLING SEQUENCE:
;       byt2strarr, barr, tarr
; INPUTS:
;       barr = byte array with text.   in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       tarr = text string array.      out
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
;         various lengths.  See also strarr2byt, the inverse.
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
	pro byt2strarr, barr, tarr, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Unpack a string array from a byte array'
	  print,' byt2strarr, barr, tarr'
	  print,'   barr = byte array with text.   in'
	  print,'   tarr = text string array.      out'
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
	  print,'   various lengths.  See also strarr2byt, the inverse.'
	  return
	endif
 
	tarr = ''			; Null string for special case.	
	if n_elements(barr) lt 3 then return	; Null string.
	mx = barr(1)			; Length of longest string.
	num = barr(0)			; Number of srtings.
	b = bytarr(mx, num)		; Set up byte array of needed size.
 
	in = 3				; Next extraction point.
	for i=0, num-1 do begin		; Loop through all strings.
	  len = barr(in-1)		; Length of next string.
	  if len gt 0 then b(0,i)=barr(in:in+len-1)	; Move ith string.
	  in = in+1+len			; Update extraction point index.
	endfor
 
	tarr = string(b)		; Convert to string array.
 
	return
	end
