;-------------------------------------------------------------
;+
; NAME:
;       TNAXES
; PURPOSE:
;       Find nice time axis tics.
; CATEGORY:
; CALLING SEQUENCE:
;       tnaxes, xmn, xmx, nx, mjx1, mjx2, xinc, [mnx2, mnx2, xinc2]
; INPUTS:
;       xmn, xmx = Axis min and max in sec.          in
;       nx = Desired number of axis tics.            in
; KEYWORD PARAMETERS:
;       Keywords:
;         FORM=form  returns a suggested format, suitable
;           for use in formatting time axis labels.
;           Ex: h$:m$:s$, h$:m$, d$
; OUTPUTS:
;       mjx1 = first major tic position in sec.      out
;       mjx2 = last major tic position in sec.       out
;       xinc = Suggested major tic spacing in sec.   out
;       mnx1 = first minor tic position in sec.      out
;       mnx2 = last minor tic position in sec.       out
;       xinc2 = suggested minor tic spacing in sec.  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 18 Nov, 1988.
;       R. Sterner, 22 Feb, 1991 --- converted to IDL V2.
;       R. Sterner, 25 Feb, 1991 --- added minor ticks.
;       R. Sterner, 2003 Nov 11 --- Dropped formats of I$, use n$ 0d$ instead.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro tnaxes, dx0,dx1,nx, mjx1,mjx2,xi, mnx1, mnx2, xi2, $
	  help=hlp, form=form
 
	if (n_params(0) lt 6) or (keyword_set(hlp)) then begin
	  print,' Find nice time axis tics.'
	  print,' tnaxes, xmn, xmx, nx, mjx1, mjx2, xinc, [mnx2, mnx2, xinc2]'
	  print,'   xmn, xmx = Axis min and max in sec.          in'
	  print,'   nx = Desired number of axis tics.            in'
	  print,'   mjx1 = first major tic position in sec.      out'
	  print,'   mjx2 = last major tic position in sec.       out'
	  print,'   xinc = Suggested major tic spacing in sec.   out'
	  print,'   mnx1 = first minor tic position in sec.      out'
	  print,'   mnx2 = last minor tic position in sec.       out'
	  print,'   xinc2 = suggested minor tic spacing in sec.  out'
	  print,' Keywords:'
	  print,'   FORM=form  returns a suggested format, suitable'
	  print,'     for use in formatting time axis labels.'
	  print,'     Ex: h$:m$:s$, h$:m$, d$'
	  return
	endif
 
	dx = double(dx1 - dx0)	; Axis range.
 
	if dx gt 0 then begin	; Forward axis.
	  x0 = double(dx0)
	  x1 = double(dx1)
	endif else begin	; Reverse axis.
	  x0 = double(dx1)
	  x1 = double(dx0)
	endelse
 
	xinc = (x1-x0)/nx	; Approx. inc size.
 
	;------------  Less than 1 sec (error)  -------------------
	if xinc lt 1. then begin	; < 1 sec.
	 print,'Warning in TNAXES: Time axis tic spacings<1 sec not recommended'
;	 stop
	endif
	;------------  1 sec to 1 min  -----------------
	if xinc lt 60. then begin	; xinc in sec < 1 min.
	  xi = 60.
	  xi2 = 15.
	  if xinc lt 42.4 then begin xi = 30. & xi2 = 10. & endif
	  if xinc lt 21.2 then begin xi = 15. & xi2 = 5.  & endif
	  if xinc lt 12.2 then begin xi = 10. & xi2 = 2.  & endif
	  if xinc lt 7.1  then begin xi = 5.  & xi2 = 1.  & endif
	  if xinc lt 3.2  then begin xi = 2.  & xi2 = 0.5 & endif
	  if xinc lt 1.4  then begin xi = 1.  & xi2 = 0.2 & endif
	  form = 'h$:m$:s$'
	  if xi gt 30. then form = 'h$:m$'
	  goto, done
	endif
	;------------  1 min to 1 hr  -------------------
	xinc = xinc/60.
	if xinc lt 60. then begin	; xinc in min < 1 hr.
	  xi = 60.
	  xi2 = 15.
	  if xinc lt 42.4 then begin xi = 30. & xi2 = 10. & endif
	  if xinc lt 21.2 then begin xi = 15. & xi2 = 5.  & endif
	  if xinc lt 12.2 then begin xi = 10. & xi2 = 2.  & endif
	  if xinc lt 7.1  then begin xi = 5.  & xi2 = 1.  & endif
	  if xinc lt 3.2  then begin xi = 2.  & xi2 = 0.5 & endif
	  if xinc lt 1.4  then begin xi = 1.  & xi2 = 0.2 & endif
	  form = 'h$:m$'
	  xi = xi*60.	; want step in sec.
	  xi2 = xi2*60.
	  goto, done
	endif
	;-------------  1 hr to 1 day  -----------------
	xinc = xinc/60.
	if xinc lt 24. then begin	; XINC in hr < 1 day.
	  xi = 24.
	  xi2 = 6.
	  if xinc lt 17  then begin xi = 12. & xi2 = 3.   & endif
	  if xinc lt 8.5 then begin xi = 6.  & xi2 = 2.   & endif
	  if xinc lt 4.9 then begin xi = 4.  & xi2 = 1.   & endif
	  if xinc lt 2.8 then begin xi = 2.  & xi2 = 0.5  & endif
	  if xinc lt 1.4 then begin xi = 1.  & xi2 = 0.25 & endif
	  form = 'h$:m$'
;	  if xi gt 4 then form = 'h$:m$@d$'
	  if xi gt 2 then form = 'h$:m$@d$'
;	  if xi gt 12. then form = 'I$'
	  if xi gt 12. then form = 'n$ 0d$'
	  xi = xi*3600.	; want step in sec.
	  xi2 = xi2*3600.
	  goto, done
	endif
	;---------------  greater than 1 day  -----------------
	xinc = xinc/24.		; xinc is in days.
	p = alog10(xinc)	; Scale to 1 to 10.
	if p lt 0 then p = p-1.
	p = fix(p)
	pow = 10.^p
	xi = xinc/pow
	xinc = xi
	;------ Set increment to a nice value -----------
	xi = 10.			; Filter scaled increment
	xi2 = 2.
	if xinc lt 7.07 then begin xi = 5.   & xi2 = 1.   & endif
	if xinc lt 3.5  then begin xi = 2.5  & xi2 = 0.5  & endif
	if xinc lt 2.24 then begin xi = 2.   & xi2 = 0.5  & endif
	if xinc lt 1.4  then begin xi = 1.   & xi2 = 0.25 & endif
	if xi ge 10. then begin
	  xi = 1.
	  p = p + 1.
	  pow = pow*10.
	endif
	xi = 86400*xi*pow	; xi = true increment.
	xi2 = 86400.*xi2*pow
;	form = 'I$'
	form = 'n$ 0d$'
 
done:	if dx le 0. then begin xi = -xi & xi2 = -xi2 & endif
	inrange, xi, dx0, dx1, mjx1, mjx2
	inrange, xi2, dx0, dx1, mnx1, mnx2
 
	return
 
	end
