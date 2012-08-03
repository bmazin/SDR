;-------------------------------------------------------------
;+
; NAME:
;       D2DMS
; PURPOSE:
;       Function to convert from degrees to deg, min, sec.
; CATEGORY:
; CALLING SEQUENCE:
;       s = d2dms( deg)
; INPUTS:
;       deg = input in degrees (scalar or array). in
; KEYWORD PARAMETERS:
;       Keywords:
;         FRACTION=nd Show fractional seconds to nd places.
;           Seconds are rounded to nearest if FRACTION not used.
;         DIGITS=n  Force degrees to have n digits.
;        /NODEG    No degree symbol added.
; OUTPUTS:
;       s = output string.                        out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1997 Jan 17
;       R. Sterner, 2002 Jan 30 --- allowed input to be an array.
;       R. Sterner, 2002 Apr 26 --- Added optional seconds fraction.
;       R. Sterner, 2002 Apr 28 --- Fixed a roundoff error.
;       R. Sterner, 2002 May 06 --- Fixed another roundoff error.
;       R. Sterner, 2006 Mar 21 --- Moved " after seconds fraction.
;
; Copyright (C) 1997, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function d2dms, a0, help=hlp, digits=digits, nodeg=nodeg, fraction=frac
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Function to convert from degrees to deg, min, sec.'
	  print,' s = d2dms( deg)'
	  print,'   deg = input in degrees (scalar or array). in'
	  print,'   s = output string.                        out'
	  print,' Keywords:'
	  print,'   FRACTION=nd Show fractional seconds to nd places.'
	  print,'     Seconds are rounded to nearest if FRACTION not used.'
	  print,'   DIGITS=n  Force degrees to have n digits.'
	  print,'  /NODEG    No degree symbol added.'
	  return,''
	endif
 
	n = n_elements(a0)
	out = strarr(n)
 
	ds = string(176B)	; Deg symbol.
	if keyword_set(nodeg) then ds=''
	ms = string(39B)
	ss = string(34B)
 
	for i=0, n-1 do begin
	  a = a0(i)
	  ;----  Break degrees into deg, min, sec  -----------
	  sn = a lt 0.	; Sign.
	  aa = abs(a)
	  d = fix(aa)	; Degrees.
	  t = (aa-d)*60.
	  m = fix(t)	; Minutes.
	  if n_elements(frac) gt 0 then begin
	    sec = (t-m)*60D0
	    f1 = '20'
	    f2 = strtrim(frac,2)
	    fmt = '(F'+f1+'.'+f2+')'
	    tmp = string(sec,form=fmt)
	    s = getwrd(tmp,0,del='.')
	    sfrac = '.'+getwrd(tmp,1,del='.')
	    ;---  Deal with overflow  -------
	    if s eq 60 then begin   ; Due to rounding in string.
	      m = m + 1		    ; Add to minutes.
	      s = 0		    ; Set seconds to 0.
	    endif
	    if m eq 60 then begin   ; Due to seconds overflow.
	      d = d + 1		    ; Add to degrees.
	      m = 0		    ; Set minutes to 0.
	    endif
	  endif else begin
	    s = round((t-m)*60.)
	    if s eq 60 then begin	; Deal with seconds > 59.5.
	      m = m + 1
	      s = 0
	    endif
	    if m eq 60 then begin   ; Due to seconds overflow.
	      d = d + 1		    ; Add to degrees.
	      m = 0		    ; Set minutes to 0.
	    endif
	    sfrac = ''			; No fractions.
	  endelse
 
	  ;----  Format output string  --------------
	  if n_elements(digits) gt 0 then begin
	    frm = '(I'+strtrim(digits,2)+'.'+strtrim(digits,2)+')'
	    dt = string(d,form=frm)
	  endif else dt = strtrim(d,2)
	  if sn eq 1 then dt='-'+dt else dt=' '+dt
	  dt = dt+ds
 
	  mt = string(m,form='(I2.2)')
	  st = string(s,form='(I2.2)')
 
;	  out(i) = dt+' '+mt+ms+' '+st+ss+sfrac
	  out(i) = dt+' '+mt+ms+' '+st+sfrac+ss
	endfor
 
	if n eq 1 then out=out(0)
	return,out
 
	end
