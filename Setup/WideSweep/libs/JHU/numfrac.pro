;-------------------------------------------------------------
;+
; NAME:
;       NUMFRAC
; PURPOSE:
;       Convert a number to a decimal string with n places.
; CATEGORY:
; CALLING SEQUENCE:
;       ss = numfrac(val, n)
; INPUTS:
;       val = value to convert (may be an array).   in
;       n = number of decimal places (def=0).       in
; KEYWORD PARAMETERS:
;       Keywords:
;         DIGITS=nd  Force number of digits to nd.
;           Only for n=0, no decimal places.
; OUTPUTS:
;       ss = resulting string.                      out
; COMMON BLOCKS:
; NOTES:
;       Notes: Why is this routine needed?  Try the following:
;         print,string(230d0-5e-14,format='(I3)')
;         Try it again without the format.  The I format does
;         not round, but the F format does.  This routine
;         uses that fact and makes it convenient to do.
;         The result has no spaces on the ends so varying length
;         values will not line up (except integers).
; MODIFICATION HISTORY:
;       R. Sterner, 1998 May 22
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function numfrac, val, dec, digits=dig, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert a number to a decimal string with n places.'
	  print,' ss = numfrac(val, n)'
	  print,'   val = value to convert (may be an array).   in'
	  print,'   n = number of decimal places (def=0).       in'
	  print,'   ss = resulting string.                      out'
	  print,' Keywords:'
	  print,'   DIGITS=nd  Force number of digits to nd.'
	  print,'     Only for n=0, no decimal places.'
	  print,' Notes: Why is this routine needed?  Try the following:'
	  print,"   print,string(230d0-5e-14,format='(I3)')"
	  print,'   Try it again without the format.  The I format does'
	  print,'   not round, but the F format does.  This routine'
	  print,'   uses that fact and makes it convenient to do.'
	  print,'   The result has no spaces on the ends so varying length'
	  print,'   values will not line up (except integers).'
	  return,''
	endif
 
	;----------------------------------------------------------------
	;  Determine needed formats
	;  Need 1 place for each integer digit: floor(alog10(abs(val)))+1
	;  Need 1 place for the sign if val < 0: s
	;  Need one place for the decimal point.
	;  Need dec decimal places.
	;  Need to make sure val is GT 0: abs(val)>1
	;----------------------------------------------------------------
	if n_elements(dec) eq 0 then dec=0
	s = val lt 0				; Sign.
	ii = strtrim(((floor(alog10(abs(val)>1))+1)>1)+1+dec+s,2)
	fmt = '(F'+ii+'.'+strtrim(dec,2)+')'
 
	;----------------------------------------------------------------
	;  Convert each values based on its format
	;  Unfortunately string does not allow an array of formats,
	;  and strmid does not allow an array of lengths.  So the loop
	;  is needed.
	;----------------------------------------------------------------
	nv = n_elements(val)
	out = strarr(nv)
	if n_elements(dig) eq 0 then dig=0
	for i=0,nv-1 do begin
	  t = string(val(i),fmt(i))
	  ;------  Integers, special case  -------
	  if dec eq 0 then begin
	    t = strmid(t,0,strlen(t)-1)  		; Drop dec pt.
	    if dig gt 0 then t=spc(dig,char='0',t)+t	; Leading 0s.
	  endif
	  out(i) = t
	endfor
	if nv eq 1 then out=out(0)			; Assume scalar.
 
	return,out
	end
