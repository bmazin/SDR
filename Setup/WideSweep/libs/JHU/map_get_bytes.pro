;-------------------------------------------------------------
;+
; NAME:
;       MAP_GET_BYTES
; PURPOSE:
;       Get extra info from resmap embedded scaling array.
; CATEGORY:
; CALLING SEQUENCE:
;       map_get_bytes, code, bb
; INPUTS:
;       code = Code for new info.       in
; KEYWORD PARAMETERS:
;       Keywords:
;         /LIST list extra info codes found in image.
;         IMAGE=img Give image instead of reading from the screen.
;         ERROR=err Error flag: 0=ok, else error (2=code not found).
; OUTPUTS:
;       bb = Byte array with new info.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: Returns extra info added by map_put_bytes.
;         Looks through added info for the specified code value,
;         returns a byte array if code was found.  The calling
;         routine must convert the byte array back to the original
;         values.
;       
;         See also map_put_bytes.pro.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Mar 18
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro map_get_bytes, code, bb, error=err, image=img, $
	  list=list, help=hlp
 
	if (n_params(0) eq 1) or keyword_set(hlp) then begin
	  print,' Get extra info from resmap embedded scaling array.'
	  print,' map_get_bytes, code, bb'
	  print,'   code = Code for new info.       in
	  print,'   bb = Byte array with new info.  out'
	  print,' Keywords:'
	  print,'   /LIST list extra info codes found in image.'
	  print,'   IMAGE=img Give image instead of reading from the screen.'
	  print,'   ERROR=err Error flag: 0=ok, else error (2=code not found).'
	  print,' Notes: Returns extra info added by map_put_bytes.'
	  print,'   Looks through added info for the specified code value,'
	  print,'   returns a byte array if code was found.  The calling'
	  print,'   routine must convert the byte array back to the original'
	  print,'   values.'
	  print,' '
	  print,'   See also map_put_bytes.pro.'
	  return
	endif
 
	packlen = 160		; Length in bytes of pack array.
	err = 1
 
	;------  Get last image line  ----------------
	if n_elements(img) ne 0 then begin
	  img_split,img,r,g,b
	  t = b(*,0)
	endif else begin
	  t = tvrd(0,0,!d.x_size,1,chan=3)
	endelse
 
	;-------  Check if image line long enough  ---------
	lst = n_elements(t)-1		; Last byte in line.
	if lst lt (packlen+2) then begin
	  print,' Error in map_get_bytes: Image not wide enough for'
	  print,'   any extra data.'
	  return
	endif
 
	if keyword_set(list) then goto, list0
	if n_params(0) lt 1 then goto, list0
 
	;----  Loop through image line looking for code  -------
	in = packlen
loop:	a = fix(t(in:in+3),0,2)		; a(0)=code, a(1)=# bytes.
	icode = a(0)			; Extra info code at this point.
	if (icode lt 10001) or (icode gt 10100) then begin
	  err = 2			; Code not found.
	  return			; Normal "not there" exit.
	endif
	nb = a(1)			; # bytes in extra info.
	if icode eq code then begin	; Found target code.
	  lo = in+4			; Start of byte array.
	  hi = lo+nb-1			; End of byte array.
	  if hi gt lst then begin	; Truncated data.
	    print,' Error in map_get_bytes: value truncated, image not'
	    print,'   wide enough for extra data.'
	    return
	  endif
	  bb = t(lo:hi)			; Return found data.
	  err = 0
	  return
	endif
	in = in + 4 + nb		; Keep looking, next point.
	if (in+4) gt lst then begin
	  err = 2			; Code not found.
	  return			; This path is rare.
	endif
	goto, loop			; Keep looking.
 
	;-----------  List extra info codes  --------------------
list0:	print,' '
	print,' Codes for extra info embedded in image'
	print,'     Code     # bytes'
	in = packlen			; Search start byte.
	num = 0				; # codes found.
list:	a = fix(t(in:in+3),0,2)		; a(0)=code, a(1)=# bytes.
	icode = a(0)			; Extra info code at this point.
	if (icode lt 10001) or (icode gt 10100) then begin
	  goto, done			; No extra info here.
	endif
	nb = a(1)			; # bytes in extra info.
	lo = in+4			; Start of byte array.
	hi = lo+nb-1			; End of byte array.
	if hi gt lst then begin		; Truncated data.
	  print,' Error in map_get_bytes: value truncated, image not'
	  print,'   wide enough for extra data.'
	  goto, done
	endif
	print,'  ',icode,nb
	num = num + 1
	in = in + 4 + nb		; Keep looking, next point.
	if (in+4) gt lst then begin
	  goto, done			; This path is rare.
	endif
	goto, list			; Keep looking.
done:
	if num eq 0 then print,'     No extra info codes found.'
 
	end
