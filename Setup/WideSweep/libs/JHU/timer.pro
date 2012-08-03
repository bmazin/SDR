;-------------------------------------------------------------
;+
; NAME:
;       TIMER
; PURPOSE:
;       Measure elapsed time between calls.
; CATEGORY:
; CALLING SEQUENCE:
;       timer, [dt]
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /RESET  resets timer to 0.
;         /START  starts timer.
;         /STOP   stops timer (actually updates elapsed time).
;         /SUM    Use with /STOP to total elapsed time. Must use
;           /START and /STOP as pairs for this to make sense.
;           Do not do a /stop without a /start.
;         /PRINT  prints timer report.
;         NUMBER = n. Select timer number to use (default = 0).
;            Timer numbers 0 through 9 may be used.
;         COMMENT = cmt_text. Causes /PRINT to print:
;           cmt_text elapsed time: hh:mm:ss (nnn sec)
; OUTPUTS:
;       dt = optionally returned elapsed time in seconds.    out
; COMMON BLOCKS:
;       timer_com
; NOTES:
;       Notes:
;        Examples:
;        timer, /start  use this call to start timer.
;        timer, /stop, /print, dt   use this call to stop timer
;          and print start, stop, elapsed time.  This example also
;          returns elapsed time in seconds.
;        Timer must be started before any elapsed time is available.
;        Timer may be stopped any number of times after starting once, and
;        the elapsed time is the time since the last timer start.
;        timer, /start, number=5   starts timer number 5.
;        timer, /stop, /print, number=5   stops timer number 5
;        and prints result.
; MODIFICATION HISTORY:
;       R. Sterner, 17 Nov, 1989
;       R. Sterner, 28 Sep, 1993 --- Used dt_tm_tojs to handle long intervals.
;       R. Sterner,  2 Dec, 1993 --- Now uses systime(1) for high precision.
;       R. Sterner,  2004 Jul 07 --- Now only updates dt on /STOP.
;       R. Sterner,  2004 Jul 07 --- Added /SUM and /CLEAR.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro timer, dt, start=strt, stop=stp, print=prnt, number=numb, $
	  comment=cmt, sum=sum, reset=reset, help=hlp
 
	common timer_com, t1, t2, dtc, toff
 
	if keyword_set(hlp) then begin
hh:	  print,' Measure elapsed time between calls.'
	  print,' timer, [dt]'
	  print,'   dt = optionally returned elapsed time in seconds.    out'
	  print,' Keywords:'
	  print,'   /RESET  resets timer to 0.'
	  print,'   /START  starts timer.'
	  print,'   /STOP   stops timer (actually updates elapsed time).'
	  print,'   /SUM    Use with /STOP to total elapsed time. Must use'
	  print,'     /START and /STOP as pairs for this to make sense.'
	  print,'     Do not do a /stop without a /start.'
	  print,'   /PRINT  prints timer report.'
	  print,'   NUMBER = n. Select timer number to use (default = 0).'
	  print,'      Timer numbers 0 through 9 may be used.'
	  print,'   COMMENT = cmt_text. Causes /PRINT to print:'
	  print,'     cmt_text elapsed time: hh:mm:ss (nnn sec)'
	  print,' Notes:'
	  print,'  Examples:'
	  print,'  timer, /start  use this call to start timer.'
	  print,'  timer, /stop, /print, dt   use this call to stop timer'
	  print,'    and print start, stop, elapsed time.  This example also'
	  print,'    returns elapsed time in seconds.'
	  print,'  Timer must be started before any elapsed time is available.'
	  print,'  Timer may be stopped any number of times after starting '+$
	    'once, and'
	  print,'  the elapsed time is the time since the last timer start.'
	  print,'  timer, /start, number=5   starts timer number 5.'
	  print,'  timer, /stop, /print, number=5   stops timer number 5'
	  print,'  and prints result.'
	  return
	endif
 
	if n_elements(t1) eq 0 then begin	; Set up storage for:
	  t1 = dblarr(10)			;   Start time in Julian Sec.
	  t2 = dblarr(10)			;   Stop time in Julian Sec.
	  dtc = dblarr(10)			;   Time diff.
	  js0 = dt_tm_tojs('1970 Jan 1')	; systime(1) seconds from.
	  gmtoff = gmt_offsec()			; Offset in sec to GMT.
	  toff = js0 - gmtoff			;   Offset to local J.S.
	endif
 
	c = 0					; Keyword detected flag.
	num = 0					; Default timer number.
	if keyword_set(numb) then num = numb	; Default timer number.
	snum = strtrim(num,2)			; Timer number as text.
 
	if keyword_set(reset) then begin	; Reset timer to 0.
	  dtc(num) = 0.
	  t1(num) = systime(1) + toff		; Start time in Julian Sec.
	  t2(num) = systime(1) + toff		; Stop time in Julian Sec.
	  c = 1
	endif
 
	if keyword_set(strt) then begin		; Timer start.
	  t1(num) = systime(1) + toff		; Start time in Julian Sec.
	  c = 1
	endif
 
	if keyword_set(stp) then begin		; Timer stop.
	  if t1(num) eq 0. then begin
	    print,' Error: Timer '+snum+' has not been started.'
	    print,' Do  timer, /start  first.'
	    return
	  endif
	  t2(num) = systime(1) + toff		; Stop time in Julian Sec.
	  if keyword_set(sum) then begin	; Totaled time.
	    dtc(num) = (t2(num)-t1(num))+dtc(num)
	  endif else begin			; Seconds since last /start.
	    dtc(num) = t2(num) - t1(num)
	  endelse
	  c = 1
	endif
 
	if arg_present(dt) then begin
	  dt = dtc(num)				; Returned time since last STOP.
	  c = 1
	endif
 
	if keyword_set(prnt) then begin		; Print timer status.
	  if t1(num) eq 0. then begin
	    print,' Error: Timer '+snum+' has not been started.'
	    print,' Do  timer, /start  first.'
	    return
	  endif
	  if t2(num) eq 0. then begin
	    print,' Error: Timer '+snum+$
	      ' must be stopped before elapsed time is available.'
	    print,' Do  timer, /stop, /print'
	    return
	  endif
	  c = 1
	  if not keyword_set(cmt) then begin	; No comment provided.
	    print,' Timer '+snum+' started: '+dt_tm_fromjs(t1(num))
	    print,' Timer '+snum+' stopped: '+dt_tm_fromjs(t2(num))
	    print,' Elapsed time: ',strsec(dtc(num))+' ('+$
	      strtrim(dtc(num),2)+' sec)'
	  endif else begin			; Use provided comment.
	    print,cmt+' elapsed time: ',strsec(dtc(num))+' ('+$
	      strtrim(dtc(num),2)+' sec)'
	  endelse
	endif
 
	if c ne 1 then goto, hh
 
	return
	end
