;-------------------------------------------------------------
;+
; NAME:
;       PRECESS_RES
; PURPOSE:
;       Precess celestial coordinates to a new date.
; CATEGORY:
; CALLING SEQUENCE:
;       precess_res, date1, ra1, dec1, date2, ra2, dec2
; INPUTS:
;       date1 = original date (like '1 Jan, 1950'). in.
;       ra1 = original R.A. in hrs.                 in.
;       dec1 = original Dec in deg.                 in.
;       date2 = new date (like '25 Nov, 1987').     in.
; KEYWORD PARAMETERS:
;       Keywords:
;         DRA=dra Returned Delta RA (hrs).
;         DDEC=ddec Delta DEC (deg).
; OUTPUTS:
;       ra2 = new R.A. in hrs.                      out.
;       dec2 = new Dec in deg.                      out.
; COMMON BLOCKS:
; NOTES:
;       Notes: Low accuracy.  Use Goddard Astro Lib precess for
;         better results.
;       
; MODIFICATION HISTORY:
;       R. Sterner. 25 Nov, 1987.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 17 Oct, 1989 --- converted to SUN.
;       R. Sterner, 2004 Feb 03 --- renamed to avoid Goddard Astro Lib conflict.
;       R. Sterner, 2004 Feb 03 --- rewrote.  Still low accuracy.
;
; Copyright (C) 1987, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	PRO PRECESS_res, DATE1, RA1, DEC1, DATE2, RA2, DEC2, help=hlp, $
	  dra=dra, ddec=ddec
 
	IF (N_PARAMS(0) LT 6) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Precess celestial coordinates to a new date.'
	  PRINT,' precess_res, date1, ra1, dec1, date2, ra2, dec2' 
	  PRINT,"   date1 = original date (like '1 Jan, 1950'). in."
	  PRINT,'   ra1 = original R.A. in hrs.                 in.'
	  PRINT,'   dec1 = original Dec in deg.                 in.'
	  PRINT,"   date2 = new date (like '25 Nov, 1987').     in."
	  PRINT,'   ra2 = new R.A. in hrs.                      out.'
	  PRINT,'   dec2 = new Dec in deg.                      out.'
	  print,' Keywords:'
	  print,'   DRA=dra Returned Delta RA (hrs).'
	  print,'   DDEC=ddec Delta DEC (deg).'
	  print,' Notes: Low accuracy.  Use Goddard Astro Lib precess for'
	  print,'   better results.'
	  PRINT,' '
	  RETURN
	ENDIF
 
	PI2 = 360./!RADEG
 
	jd1 = date2jd(date1)
	if jd1 eq 0 then begin
	  print,' Error in precess_res: date1 error.'
	  return
	endif
	jd2 = date2jd(date2)
	if jd2 eq 0 then begin
	  print,' Error in precess_res: date2 error.'
	  return
	endif
	jd = (jd1+jd2)/2.		; Use midpoint rates.
	dt = (jd2-jd1)/365.25		; Time interval in years.
	T = (jd-2000.)/36525		; Julian centuries from 2000 to midpt.
	M = 3.07496 + 0.00186*T		; Seconds of time.
	N = 20.0431 + 0.00850*T		; Seconds of arc.
 
	DRA = (M/3600.) + (N/15./3600.)*SIN(RA1/24.*PI2)*TAN(DEC1/!RADEG)
	DDEC = (N/3600.)*COS(RA1/24.*PI2)
 
	RA2 = RA1 + DRA*dt
	DEC2 = DEC1 + DDEC*dt
 
	RETURN
	END
