;-------------------------------------------------------------
;+
; NAME:
;       TYP2NUM
; PURPOSE:
;       Convert datatype description to corresponding numeric zero.
; CATEGORY:
; CALLING SEQUENCE:
;       num = typ2num(txt)
; INPUTS:
;       txt = datatype description in a text string.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         /BYTES Instead of numeric item return total bytes in item.
;         BITS=nbits nbits is the total number of bits in given item.
;         FTYPE=ftyp Returned upper case full type name.
;         ERROR=err  Error flag: 0=ok, else error.
;         /QUIET  Do not print error message.
; OUTPUTS:
;       num = numeric item (0) of specified typ.       out
; COMMON BLOCKS:
; NOTES:
;       Note: Uses the IDL EXECUTE function.
;         Datatypes are: CHR, BYT, INT, LON, FLT, DBL, COMPLEX,
;         DCOMPLEX, UINT, ULON, LON64, ULON64 (CHR is 1 byte).
;         Any array dimensions follow the data type in parantheses.
;         Examples: "UINT","FLT","BYT(3,4)","LON(100)".
;         May also use ARR before dimensions: bytarr(2,3), LONARR(7).
;         Roughly the inverse of datatype.  Data type STR
;         is also allowed.  Data type DMS means
;         'Degrees Minutes Seconds' and is considered a string
;         which must be handled as a special case in the user code:
;         For example: if typ eq 'DMS' then out=dms2d(in).
;         Data types may be abbreviated:
;           CH, B, I, L, F, D, C, DC, UI, UL, L64, UL64, S, DM.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Oct 10
;       R. Sterner, 2003 Aug 26 --- Allowed abbreviations, added STR,
;       also fixed (u)long60 -> (u)lon64.
;       R. Sterner, 2005 Mar 03 --- Allowed arr or ARR in datatype.
;       R. Sterner, 2005 Mar 03 --- Added /BYTES.
;       R. Sterner, 2006 Mar 21 --- Added new type DMS and FTYPE=ftyp.
;       R. Sterner, 2006 May 07 --- Fixed to work for FLT=7.2 type inputs.
;       R. Sterner, 2006 May 07 --- Revised array/scalar testing.
;       R. Sterner, 2007 Sep 12 --- Slightly improved help text.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function typ2num, input0, bits=bits, error=err, quiet=quiet, $
	  bytes=bytes, ftype=ftyp, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert datatype description to corresponding numeric zero.'
	  print,' num = typ2num(txt)'
	  print,'   txt = datatype description in a text string.   in'
	  print,'   num = numeric item (0) of specified typ.       out'
	  print,' Keywords:'
	  print,'   /BYTES Instead of numeric item return total bytes in item.'
	  print,'   BITS=nbits nbits is the total number of bits in given item.'
	  print,'   FTYPE=ftyp Returned upper case full type name.'
	  print,'   ERROR=err  Error flag: 0=ok, else error.'
	  print,'   /QUIET  Do not print error message.'
	  print,' Note: Uses the IDL EXECUTE function.'
	  print,'   Datatypes are: CHR, BYT, INT, LON, FLT, DBL, COMPLEX,'
	  print,'   DCOMPLEX, UINT, ULON, LON64, ULON64 (CHR is 1 byte).'
	  print,'   Any array dimensions follow the data type in parantheses.'
	  print,'   Examples: "UINT","FLT","BYT(3,4)","LON(100)".'
	  print,'   May also use ARR before dimensions: bytarr(2,3), LONARR(7).'
	  print,'   Roughly the inverse of datatype.  Data type STR'
	  print,'   is also allowed.  Data type DMS means'
	  print,"   'Degrees Minutes Seconds' and is considered a string"
	  print,'   which must be handled as a special case in the user code:'
	  print,"   For example: if typ eq 'DMS' then out=dms2d(in)."
	  print,'   Data types may be abbreviated:'
	  print,'     CH, B, I, L, F, D, C, DC, UI, UL, L64, UL64, S, DM.'
	  return,''
	endif
 
	;----------------------------------------------------------
	;  Get datatype and any dimensions
	;----------------------------------------------------------
	input = strupcase(input0)		; Copy to allow change.
	input=stress(input,'d',1,'ARR','',ned)	; Ignore ARR.
 
	p = strpos(input,'(')		; Position of opening paren if any.
	aflag = 2			; Array flag.
	if ned gt 0 then aflag=1	; Had arr in descriptor.
	if strpos(input,'=') gt 0 then aflag=0	; Scalar.
	if aflag eq 2 then $
	  if (p gt 0) and ((strmid(input,0,1) ne 'C') or $
	    (strmid(input,0,2) ne 'DC')) then aflag=1
 
	;---  Array  ----------
	if aflag eq 1 then begin	; Was array.
	  typ = strmid(input,0,p)	; Datatype.
	  dim0 = strmid(input,p,99)	; Dimensions.
	  dim = 'ARR'+dim0		; Add arr.
	;---  Scalar  ----------
	endif else begin		; Was scalar.
	  typ = input			; Datatype.
	  typ = getwrd(typ,del='=')	; Allow FLT = 7.2 for example.
	  dim = ''			; Null dimension.
	endelse
	typ = strtrim(typ,2)		; Drop any excess whitespace.
 
	;----------------------------------------------------------
	;  Deal with abbreviations
	;----------------------------------------------------------
	case typ of
'B':	typ = 'BYT'
'I':	typ = 'INT'
'L':	typ = 'LON'
'F':	typ = 'FLT'
'D':	typ = 'DBL'
'C':	typ = 'COMPLEX'
'DC':	typ = 'DCOMPLEX'
'UI':	typ = 'UINT'
'UL':	typ = 'ULON'
'L64':	typ = 'LON64'
'UL64':	typ = 'ULON64'
'S':	typ = 'STR'
'CH':	typ = 'CHR'
'DM':	typ = 'DMS'
else:
	endcase
	ftyp = typ	; Return upper case full type name.
	  
	;----------------------------------------------------------
	;  Find bits and set scalar value
	;----------------------------------------------------------
	case typ of
'BYT':	   begin
	     num2 = 0B
	     nbits = 8
	   end
'INT':	   begin
	     num2 = 0
	     nbits = 16
	   end
'LON':     begin
	     num2 = 0L
	     nbits = 32
	   end
'FLT':     begin
	     num2 = 0.0
	     nbits = 32
	   end
'DBL':     begin
	     num2 = 0D0
	     nbits = 64
	   end
'COMPLEX': begin
	     num2 = complex(0.,0.)
	     nbits = 64
	   end
'DCOMPLEX':begin
	     num2 = dcomplex(0D0,0D0)
	     nbits = 128
	   end
'UINT':	   begin
	     num2 = 0U
	     nbits = 16
	     end
'ULON':    begin
	     num2 = 0UL
	     nbits = 32
	   end
'LON64':  begin
	     num2 = 0LL
	     nbits = 64
	   end
'ULON64': begin
	     num2 = 0ULL
	     nbits = 64
	   end
'STR':	   begin
	     num2 = ''
	     nbits = 0
	   end
'CHR':	   begin
	     num2 = 65B
	     nbits = 8
	     typ = 'BYT'  ; CHR not a real IDL data type.
	   end
'DMS':	   begin
	     num2 = ''
	     nbits = 0
	     typ = 'STR'  ; DMS not a real IDL data type.
	   end
else:	   begin
	     if not keyword_set(quiet) then $
	       print,' Unknown numeric datatype: ',typ
	     err = 1
	     return,''
	   end
	endcase
 
	;----------------------------------------------------------
	;  Create numeric item and compute total bits
	;----------------------------------------------------------
	;---------  Scalar item  ----------------
	if dim eq '' then begin
	  err = 0
	  bits = nbits				; Copy # bits.
	  if keyword_set(bytes) then return,nbits/8
	  return, num2				; Return scalar number.
	;--------  Array  ------------------------
	endif else begin
	  if keyword_set(bytes) then begin
	    dim0 = strmid(dim0,1,strlen(dim0)-2)  ; Drop parens.
	    wordarray,dim0,del=',',list		; Array of indices.
	    nel = ulong(product(ulong64(list)))	; Number of elements.
	    bits = nbits*nel			; Total # bits.
	    return, bits/8
	  endif
	  err = 1 - execute('num='+typ+dim)	; Create array.
	  if err ne 0 then return, 0		; Error.
	  bits = nbits*n_elements(num)		; Total # bits.
	  return, num				; Return array.
	endelse
 
	end
