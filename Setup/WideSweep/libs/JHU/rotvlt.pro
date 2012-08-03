;-------------------------------------------------------------
;+
; NAME:
;       ROTVLT
; PURPOSE:
;       Rotate current vlt or part of it.
; CATEGORY:
; CALLING SEQUENCE:
;       rotvlt
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         STEP=value sets rotation step size.
;         /REVERSE reverses rotation direction.
;         RANGE=[lo,hi] sets rotation range (def = 1 to 255).
;         WAIT = seconds sets wait time between color shifts.
;         SOUND=time does sound effects, time 1/8192 sec long for each R,G,B.
;         CHORD=time. Like SOUND but does R,G,B together.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Press any key to exit.
; MODIFICATION HISTORY:
;       R. Sterner, 15 Aug, 1989
;       R. Sterner, 27 Jan, 1993 --- dropped reference to array.
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro rotvlt, q, help=hlp, step=st, reverse=rev, range=rng,$
	   wait=wt, sound=snd, chord=chrd
 
	if keyword_set(hlp) then begin
	  print,' Rotate current vlt or part of it.'
	  print,' rotvlt'
	  print,'   No args.'
	  print,' Keywords:'
	  print,'   STEP=value sets rotation step size.'
	  print,'   /REVERSE reverses rotation direction.'
	  print,'   RANGE=[lo,hi] sets rotation range (def = 1 to 255).'
	  print,'   WAIT = seconds sets wait time between color shifts.'
	  print,'   SOUND=time does sound effects, time 1/8192 sec long '+$
	    'for each R,G,B.'
	  print,'   CHORD=time. Like SOUND but does R,G,B together.'
	  print,' Notes: Press any key to exit.' 
	  return
	endif
 
	tvlct, r, g, b, /get			; Read current color table.
 
	;-----  Set up wait time  ---------
	if not keyword_set(wt) then wt = 0	; Default is no wait.
 
	;-----  rotattion step size  -----
	stp = 1					; Default.
	if keyword_set(st) then stp = st	; Use keyword if available.
 
	;-----  rotation direction  -------
	if keyword_set(rev) then stp = -stp	; Reverse step?
 
	;-----  rotation range  ------
	top = topc()				; Top color index.
	hi = top				; Default hi.
	if n_elements(rng) eq 0 then rng = [1,top]  ; Default range.
	if keyword_set(rng(0)) then begin	; Check range.
	  lst = n_elements(rng) - 1		; Find range array size.
	  lo = rng(0)>0				; Force LO to be non-negative.
	  if lst gt 0 then hi = rng(1)<top	; If HI force it <!d.table_size.
	  if hi lt lo then begin		; Force LO < HI.
	    t = lo
	    lo = hi
	    hi = t
	  endif
	endif
 
	if keyword_set(snd) then begin
	  if snd eq 1 then t = intarr(200) else t = intarr(snd)
	endif
 
	if keyword_set(chrd) then begin
	  if chrd eq 1 then t = intarr(200) else t = intarr(chrd)
	endif
 
	while get_kbrd(0) eq '' do begin	; Check if key pressed.
	  r(lo) = shift(r(lo:hi),stp)		; No, rotate color table.
	  g(lo) = shift(g(lo:hi),stp)
	  b(lo) = shift(b(lo:hi),stp)
	  wait, wt				; Pause for wt seconds.
	  tvlct, r, g, b			; Load rotated color table.
	  if keyword_set(snd) then begin
	    sound,t+r(lo)*7+200, /play
	    sound,t+g(lo)*7+200, /play
	    sound,t+b(lo)*7+200, /play
	  endif
	  if keyword_set(chrd) then begin
	    tmp = [[t+r(lo)*7+200],[t+g(lo)*7+200],[t+b(lo)*7+200]]
	    sound, tmp, /play
	  endif
	endwhile
 
	end
