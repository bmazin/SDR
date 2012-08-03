;-------------------------------------------------------------
;+
; NAME:
;       ETC
; PURPOSE:
;       Return estimated time to completion in seconds.
; CATEGORY:
; CALLING SEQUENCE:
;       stc = etc( fr )
; INPUTS:
;       fr = fraction of work done.             in
; KEYWORD PARAMETERS:
;       Keywords:
;        DELTA=d  interval in seconds for rate estimation (def=10).
;          DELTA must be given on each call.
;        /STATUS means display job status (at [10,12]).
;        STATUS=[x,y] display at column x, line y (from 1 at top).
; OUTPUTS:
;       stc = estimated seconds to completion.  out
; COMMON BLOCKS:
;       etc_com
; NOTES:
;       Notes: Call with fr=0 to initialize.
; MODIFICATION HISTORY:
;       R. Sterner, 25 Mar, 1993
;       R. Sterner, 1995 Jan 19 --- Added STATUS=[x,y]
;       R. Sterner, 1995 Feb  9 --- Upgraded intermediate estimates.
;       R. Sterner, 2004 Jul 07 --- Fixed for modified timer routine.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	function etc, fraction, delta=delta, status=status, help=hlp
 
	common etc_com, t0, est0, fr0
 
	if (n_params() lt 1) or keyword_set(hlp) then begin
	  print,' Return estimated time to completion in seconds.'
	  print,' stc = etc( fr )'
	  print,'   fr = fraction of work done.             in'
	  print,'   stc = estimated seconds to completion.  out'
	  print,' Keywords:'
	  print,'  DELTA=d  interval in seconds for rate estimation (def=10).'
	  print,'    DELTA must be given on each call.'
	  print,'  /STATUS means display job status (at [10,12]).'
	  print,'  STATUS=[x,y] display at column x, line y (from 1 at top).'
	  print,' Notes: Call with fr=0 to initialize.'
	  return, ''
	endif
 
	if n_elements(delta) eq 0 then delta = 10
	if n_elements(status) eq 0 then begin
	  sflag=0
	endif else begin
	  sflag=1
	  sxy = [10,12]
	  if n_elements(status) eq 2 then sxy=status
	endelse
 
	;---------  Start timer on 0 fraction  ---------
	if fraction le 0 then begin
	  timer, /start, num=9
	  est = -2
	  t0 = 0
	  fr0 = 0.0
	  est0 = -2
	  goto, done
	endif
 
	if fraction ge 1 then begin	; Fraction > 1, done.
	  est = 0
	  goto, done
	endif
 
	;---------  Get time  -------------
	timer, /stop, t, num=9		; New time.
	dsec = t - t0			; Seconds since last timer call.
	if dsec le delta then begin	; Time for new estimate?
	  est = est0-dsec		; No, use old estimate - interval.
	  goto, done
	endif
 
	;---------  Compute new estimate  --------
	est = (1.-fraction)/((fraction-fr0)/(t-t0))
	fr0 = fraction			; Save new values.
	t0 = t
	est0 = est
 
	;------  Return nearest second  --------
done:	tt = fix(.5+est)
 
	;--------  Print status  ------------
	if sflag eq 1 then begin
	  now = strmid(systime(),11,8)
	  thn = strsec(tt+secstr(now))
	  printat,sxy(0),sxy(1),'Current time: '+now
          if tt le 0 then begin
            est = ''
          endif else begin
            est = 'Estimated time to completion: '+strsec(tt)+$
              ' ('+thn+')'
          endelse
          printat,sxy(0),sxy(1)+1,est
	endif
 
	return, tt
 
	end
