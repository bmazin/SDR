;-------------------------------------------------------------
;+
; NAME:
;       D2DM
; PURPOSE:
;       Function to convert from degrees to deg, min.
; CATEGORY:
; CALLING SEQUENCE:
;       s = d2dm( deg)
; INPUTS:
;       deg = input in degrees (scalar or array). in
; KEYWORD PARAMETERS:
;       Keywords:
;         FRACTION=nd Show fractional minutes to nd places.
;           Minutes are rounded to nearest if FRACTION not used.
;         DIGITS=n  Force degrees to have n digits.
;        /NODEG    No degree symbol added.
; OUTPUTS:
;       s = output string.                        out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Oct 11
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function d2dm, a0, help=hlp, digits=digits, nodeg=nodeg, fraction=frac
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Function to convert from degrees to deg, min.'
	  print,' s = d2dm( deg)'
	  print,'   deg = input in degrees (scalar or array). in'
	  print,'   s = output string.                        out'
	  print,' Keywords:'
	  print,'   FRACTION=nd Show fractional minutes to nd places.'
	  print,'     Minutes are rounded to nearest if FRACTION not used.'
	  print,'   DIGITS=n  Force degrees to have n digits.'
	  print,'  /NODEG    No degree symbol added.'
	  return,''
	endif
 
	n = n_elements(a0)
	out = strarr(n)
 
	ds = string(176B)	; Deg symbol.
	if keyword_set(nodeg) then ds=''
	ms = string(39B)
 
	for i=0, n-1 do begin
	  a = a0(i)
	  ;----  Break degrees into deg, min, sec  -----------
	  sn = a lt 0.	; Sign.
	  aa = abs(a)
	  d = fix(aa)	; Degrees.
	  t = (aa-d)*60.
	  if n_elements(frac) gt 0 then begin
	    f1 = '20'
	    f2 = strtrim(frac,2)
	    fmt = '(F'+f1+'.'+f2+')'
	    tmp = string(t,form=fmt)
	    m = getwrd(tmp,0,del='.')
	    mfrac = '.'+getwrd(tmp,1,del='.')
	    ;---  Deal with overflow  -------
	    if m eq 60 then begin   ; Due to min overflow.
	      d = d + 1		    ; Add to degrees.
	      m = 0		    ; Set minutes to 0.
	    endif
	  endif else begin
	    m = round(t)
	    if m eq 60 then begin	; Deal with min > 59.5.
	      d = d + 1
	      m = 0
	    endif
	    mfrac = ''			; No fractions.
	  endelse
 
	  ;----  Format output string  --------------
	  if n_elements(digits) gt 0 then begin
	    frm = '(I'+strtrim(digits,2)+'.'+strtrim(digits,2)+')'
	    dt = string(d,form=frm)
	  endif else dt = strtrim(d,2)
	  if sn eq 1 then dt='-'+dt else dt=' '+dt
	  dt = dt+ds
 
	  mt = string(m,form='(I2.2)')
 
	  out(i) = dt+' '+mt+mfrac+ms
	endfor
 
	if n eq 1 then out=out(0)
	return,out
 
	end
