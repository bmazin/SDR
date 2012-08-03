;-------------------------------------------------------------
;+
; NAME:
;       TIME2JDOFF
; PURPOSE:
;       Find Julian day and offset from seconds. JS, Timeaxis
; CATEGORY:
; CALLING SEQUENCE:
;       time2jdoff, t
; INPUTS:
;       t = start time or array of times in seconds.  in
;         Time is in seconds after a reference time.
;         Reference time may be specified with the
;         REFERENCE keyword.  Default is Julian Seconds,
;         which are seconds after 0:00 Jan 1, 2000.
; KEYWORD PARAMETERS:
;       Keywords:
;         JD=jd    returned Julian Day for 0:00 of the day of
;           or just before start time in t.
;         OFF=off  returned offset in seconds which is to be
;           subtracted from t to put in in the range 0 to midnight.
;         REFERENCE=ref = date/time string (like "12:00 1 jan 1970")
;           which is the zero point for time t.  If not given this
;           refernce time is assumed to be 0:00 1 Jan, 2000.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes:  This routine is needed because IDL stores !x.crange
;         only in single precision, not good enough for time
;         intervals in seconds far from the zero time.  This gives
;         the values needed by the timeaxis routine:
;         time2jdoff, t, jd=jd, off=off, ref="1 jan, 1970"
;         plot,t-off, y, xstyle=5
;         timeaxis, jd=jd
; MODIFICATION HISTORY:
;       R. Sterner, 18 Aug, 1993
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro time2jdoff, t, jd=jd, off=off, reference=ref, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Find Julian day and offset from seconds. JS, Timeaxis'
	  print,' time2jdoff, t'
	  print,'   t = start time or array of times in seconds.  in'
	  print,'     Time is in seconds after a reference time.'
	  print,'     Reference time may be specified with the'
	  print,'     REFERENCE keyword.  Default is Julian Seconds,'
	  print,'     which are seconds after 0:00 Jan 1, 2000.'
	  print,' Keywords:'
	  print,'   JD=jd    returned Julian Day for 0:00 of the day of'
	  print,'     or just before start time in t.'
	  print,'   OFF=off  returned offset in seconds which is to be'
	  print,'     subtracted from t to put in in the range 0 to midnight.'
	  print,'   REFERENCE=ref = date/time string (like "12:00 1 jan 1970")'
	  print,'     which is the zero point for time t.  If not given this'
	  print,'     refernce time is assumed to be 0:00 1 Jan, 2000.'
	  print,' Notes:  This routine is needed because IDL stores !x.crange'
	  print,'   only in single precision, not good enough for time'
	  print,'   intervals in seconds far from the zero time.  This gives'
	  print,'   the values needed by the timeaxis routine:'
	  print,'   time2jdoff, t, jd=jd, off=off, ref="1 jan, 1970"'
	  print,'   plot,t-off, y, xstyle=5'
	  print,'   timeaxis, jd=jd'
	  return
	endif
 
	t0 = min(t)				; Starting time in t.
	if n_elements(ref) eq 0 then ref = '0:00 1 Jan 2000'	; Default.
	js_r =  dt_tm_tojs(ref)			; JS of reference.
	t0 = t0 + js_r				; Start time in JS.
	dt = dt_tm_fromjs(t0,jd=jd)		; JD of start day.
	js_jd = (jd-2451545)*86400d0		; JS of JD (at 0:00).
 	off = js_jd - js_r			; Offset to 0:00 of JD.
 
	return
	end
