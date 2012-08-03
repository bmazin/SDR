;-------------------------------------------------------------
;+
; NAME:
;       GETWINDOW
; PURPOSE:
;       Get data window coordinates.
; CATEGORY:
; CALLING SEQUENCE:
;       getwindow, xmn, xmx, ymn, ymx, [err]
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         XMID=x  gives window x midvalue.
;         YMID=y  gives window y midvalue.
; OUTPUTS:
;       xmn, xmx = window edge min and max data x.   out
;       ymn, ymx = window edge min and max data y.   out
;       err = window status: 0=ok, 1=not set.        out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 21 Feb 1990
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro getwindow, xmn, xmx, ymn, ymx, err, xmid=xmid, ymid=ymid, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Get data window coordinates.'
	  print,' getwindow, xmn, xmx, ymn, ymx, [err]'
	  print,'   xmn, xmx = window edge min and max data x.   out'
	  print,'   ymn, ymx = window edge min and max data y.   out'
	  print,'   err = window status: 0=ok, 1=not set.        out'
	  print,' Keywords:'
	  print,'   XMID=x  gives window x midvalue.'
	  print,'   YMID=y  gives window y midvalue.'
	  return
	endif
 
	xmn = !x.range(0)
	xmx = !x.range(1)
	if (xmn eq 0) and (xmx eq 0) then begin
	  xmn = !x.crange(0)
	  xmx = !x.crange(1)
	endif
 
	ymn = !y.range(0)
	ymx = !y.range(1)
	if (ymn eq 0) and (ymx eq 0) then begin
	  ymn = !y.crange(0)
	  ymx = !y.crange(1)
	endif
 
	xmid = .5*(xmn + xmx)
	ymid = .5*(ymn + ymx)
	err = 0
	if (xmn eq 0) and (xmx eq 0) then err = 1
	if (ymn eq 0) and (ymx eq 0) then err = 1
	return
 
	end
