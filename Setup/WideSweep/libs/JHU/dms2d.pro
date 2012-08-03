;-------------------------------------------------------------
;+
; NAME:
;       DMS2D
; PURPOSE:
;       Convert from Degrees, Minutes, and seconds to degrees.
; CATEGORY:
; CALLING SEQUENCE:
;       d = dms2d(s)
; INPUTS:
;       s = input text string with deg, min, sec.    in
;         Ex: "3d 08m 30s" or "3 8 30" or "3:8:30".
;         May have a leading negative sign: "-3d 08m 30s".
; KEYWORD PARAMETERS:
; OUTPUTS:
;       d = returned angle in degrees.               out
; COMMON BLOCKS:
; NOTES:
;       Notes: scalar or array inputs.  Units symbols ignored,
;         first item assumed deg, 2nd minutes, 3rd seconds.
; MODIFICATION HISTORY:
;       R. Sterner, 1998 Feb 3
;       R. Sterner, 2002 Jan 30 --- Allowed inputs to be arrays.
;       R. Sterner, 2002 Apr 26 --- Allowed dd:mm:ss form.
;       R. Sterner, 2004 Jun 24 --- Allow negative sign.
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function dms2d, in0, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert from Degrees, Minutes, and seconds to degrees.'
	  print,' d = dms2d(s)'
	  print,'   s = input text string with deg, min, sec.    in'
	  print,'     Ex: "3d 08m 30s" or "3 8 30" or "3:8:30".'
	  print,'     May have a leading negative sign: "-3d 08m 30s".'
	  print,'   d = returned angle in degrees.               out'
	  print,' Notes: scalar or array inputs.  Units symbols ignored,'
	  print,'   first item assumed deg, 2nd minutes, 3rd seconds.'
	  return,''
	endif
 
	n = n_elements(in0)
	out = dblarr(n)
 
	for i=0, n-1 do begin
	  in = strtrim(in0(i),2)	; Drop any leading/trailing spaces.
	  if strmid(in,0,1) eq '-' then begin	; Negative sign.
	    sn = -1.			; Sign of result.
	    in = repchr(in,'-')		; Replace - by space.
	  endif else sn = 1.
	  in = repchr(in,',')		; Replace , by space.
	  in = repchr(in,':')		; Replace : by space.
	  d = getwrd(in,0)		; Grab 1st item.
	  m = getwrd(in,1)		; Grab 2nd item.
	  s = getwrd(in,2)		; Grab 3rd item.
	  out(i) = sn*(d*1D0 + m/60D0 + s/3600D0)	; Combine.
	endfor
 
	if n eq 1 then out=out(0)	; If scalar in then scalar out.
 
	return, out
 
	end
