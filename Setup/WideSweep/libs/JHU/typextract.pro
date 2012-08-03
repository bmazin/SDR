;-------------------------------------------------------------
;+
; NAME:
;       TYPEXTRACT
; PURPOSE:
;       Extract a specified datatype from binary data in byte array.
; CATEGORY:
; CALLING SEQUENCE:
;       num = typextract(txt, offset, bindat)
; INPUTS:
;       txt = datatype description in a text string.   in
;       offset = offset in bytes into bindat.          in
;       bindat = binary data in a byte array.          in
; KEYWORD PARAMETERS:
;       Keywords:
;         BITS=bits Returned total number of bits in given item.
;         ERROR=err  Error flag: 0=ok, else error.
; OUTPUTS:
;       num = extracted numeric item.                  out
; COMMON BLOCKS:
; NOTES:
;       Note: datatypes are: BYT, INT, LON, FLT, DBL, COMPLEX,
;         DCOMPLEX, UINT, ULON, LONG64, ULONG64.
;         Any array dimensions follow the data type in parantheses.
;         Examples: "UINT","FLT","BYT(3,4)","LON(100)".
;         The inverse of datatype.  Note array syntax is
;         not quite like the IDL array functions, use byt(3,4)
;         for this routine instead of bytarr(3,4).
;         See also typ2num.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Oct 11
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function typextract, input, offset, bindat, bits=bits, $
	  error=err, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Extract a specified datatype from binary data in byte array.'
	  print,' num = typextract(txt, offset, bindat)'
	  print,'   txt = datatype description in a text string.   in'
	  print,'   offset = offset in bytes into bindat.          in'
	  print,'   bindat = binary data in a byte array.          in'
	  print,'   num = extracted numeric item.                  out'
	  print,' Keywords:'
	  print,'   BITS=bits Returned total number of bits in given item.'
	  print,'   ERROR=err  Error flag: 0=ok, else error.'
	  print,' Note: datatypes are: BYT, INT, LON, FLT, DBL, COMPLEX,'
	  print,'   DCOMPLEX, UINT, ULON, LONG64, ULONG64.'
	  print,'   Any array dimensions follow the data type in parantheses.'
	  print,'   Examples: "UINT","FLT","BYT(3,4)","LON(100)".'
	  print,'   The inverse of datatype.  Note array syntax is'
	  print,'   not quite like the IDL array functions, use byt(3,4)'
	  print,'   for this routine instead of bytarr(3,4).'
	  print,'   See also typ2num.'
	  return,''
	endif
 
	;----------------------------------------------------------
	;  Get datatype and any dimensions
	;----------------------------------------------------------
	p = strpos(input,'(')		; Position of opening paren if any.
	n_arr = 1L			; Will have total # elements.
	;---  Array  ----------
	if p ge 0 then begin			; Dimension was given.
	  typ = strupcase(strmid(input,0,p))	; Datatype.
	  dim = strmid(input,p+1,99)		; Dimensions.
	  wordarray,dim,tmp,del=', '		; Put dims in text array.
	  dimarr = tmp+0			; Array of dimensions.
	  for i=0,n_elements(dimarr)-1 do n_arr=n_arr*dimarr(i)
	;---  Scalar  ----------
	endif else begin			; No dimension given.
	  typ = strupcase(input)		; Datatype.
	  dim = ''				; Null dimension.
	endelse
	  
	;----------------------------------------------------------
	;  Do extraction from given byte array
	;----------------------------------------------------------
	if datatype(bindat) ne 'BYT' then begin
	  err = 1
	  print,' Error in typextract: Must give bindat as a byte array.'
	  return,''
	endif
	nbin = n_elements(bindat)		; # bytes in bindat.
	n_avail = nbin - offset			; Available bytes.
	case typ of
'BYT':	   begin
	     nbits = 8*n_arr
	     if (nbits/8) gt n_avail then goto, over
	     x = byte(bindat,offset,n_arr)
	   end
'INT':	   begin
	     nbits = 16*n_arr
	     if (nbits/8) gt n_avail then goto, over
	     x = fix(bindat,offset,n_arr)
	   end
'LON':     begin
	     nbits = 32*n_arr
	     if (nbits/8) gt n_avail then goto, over
	     x = long(bindat,offset,n_arr)
	   end
'FLT':     begin
	     nbits = 32*n_arr
	     if (nbits/8) gt n_avail then goto, over
	     x = float(bindat,offset,n_arr)
	   end
'DBL':     begin
	     nbits = 64*n_arr
	     if (nbits/8) gt n_avail then goto, over
	     x = double(bindat,offset,n_arr)
	   end
'COMPLEX': begin
	     nbits = 64*n_arr
	     if (nbits/8) gt n_avail then goto, over
	     x = complex(bindat,offset,n_arr)
	   end
'DCOMPLEX':begin
	     nbits = 128*n_arr
	     if (nbits/8) gt n_avail then goto, over
	     x = dcomplex(bindat,offset,n_arr)
	   end
'UINT':	   begin
	     nbits = 16*n_arr
	     if (nbits/8) gt n_avail then goto, over
	     x = uint(bindat,offset,n_arr)
	     end
'ULON':    begin
	     nbits = 32*n_arr
	     if (nbits/8) gt n_avail then goto, over
	     x = ulong(bindat,offset,n_arr)
	   end
'LONG64':  begin
	     nbits = 64*n_arr
	     if (nbits/8) gt n_avail then goto, over
	     x = long64(bindat,offset,n_arr)
	   end
'ULONG64': begin
	     nbits = 64*n_arr
	     if (nbits/8) gt n_avail then goto, over
	     x = ulong64(bindat,offset,n_arr)
	   end
else:	   begin
	     if not keyword_set(quiet) then $
	       print,' Unknown numeric datatype: ',typ
	     err = 1
	     return,''
	   end
	endcase
 
	;----------------------------------------------------------
	;  Reshape to correct dimensions
	;----------------------------------------------------------
	bits = nbits				; Copy # bits.
	err = 0
	;---------  Scalar item  ----------------
	if dim eq '' then begin
	  return, x(0)				; Return scalar number.
	;--------  Array  ------------------------
	endif else begin
	  x = reform(x,dimarr,/overwrite)	; Reshape array.
	  return, x
	endelse
 
	;----------------------------------------------------------
	;  Extraction over-run
	;----------------------------------------------------------
over:
	  err = 1
	  print,' Error in typextract: Trying to extract more than available.'
	  print,'   '+strtrim(n_avail,2)+' bytes left in bindat.'
	  print,'   Asking for '+strtrim(nbits/8)
	  return,''
 
 
	end
