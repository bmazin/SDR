;-------------------------------------------------------------
;+
; NAME:
;       WAIT_BAR
; PURPOSE:
;       Wait for given number of seconds, show a sliding indicator.
; CATEGORY:
; CALLING SEQUENCE:
;       wait_bar, sec
; INPUTS:
;       sec = number of seconds to wait.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         TITLE=tt Wait bar title (def=none).
;         XOFFSET=xoff, YOFFSET=yoff  Screen position from top
;           left corner.
;         COLOR=clr  Indicator color (def=green).
;         XSIZE=xsz, YSIZE=ysz Size of horizontal bar (def=200, 30).
;         TCOLOR=tclr Time text color (def=white).
;         TSIZE=tsz Time text size (def=1).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Apr 08
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro wait_bar, sec, title=tt, xoffset=xoff, yoffset=yoff, $
	  color=clr, tcolor=tclr, xsize=xsz, ysize=ysz, tsize=tsz, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Wait for given number of seconds, show a sliding indicator.'
	  print,' wait_bar, sec'
	  print,'   sec = number of seconds to wait.   in'
	  print,' Keywords:'
	  print,'   TITLE=tt Wait bar title (def=none).'
	  print,'   XOFFSET=xoff, YOFFSET=yoff  Screen position from top'
	  print,'     left corner.'
	  print,'   COLOR=clr  Indicator color (def=green).'
	  print,'   XSIZE=xsz, YSIZE=ysz Size of horizontal bar (def=200, 30).'
	  print,'   TCOLOR=tclr Time text color (def=white).'
	  print,'   TSIZE=tsz Time text size (def=1).'
	  return
	endif
 
	t0 = systime(1)			; Time now.
 
	;------  Set defaults  --------
	if n_elements(tt) eq 0 then tt=' '
	if n_elements(tclr) eq 0 then tclr=tarclr(255,255,255)
	if n_elements(clr) eq 0 then clr=tarclr(0,150,0)
	if n_elements(xsz) eq 0 then xsz=200
	if n_elements(ysz) eq 0 then ysz=30
	if n_elements(tsz) eq 0 then tsz=1
 
	;-----  Set up widget  --------
	top = widget_base(title=tt,xoff=xoff,yoff=yoff)
	id = widget_draw(top, xsize=xsz, ysize=ysz)
	widget_control, top, /real
;	widget_control, id, get_val=win
 
loop:	dt = systime(1) - t0		; Time to go.
	tleft = sec - dt		; Seconds left.
	if tleft le 0. then goto, done
	fr = 1. - tleft/sec		; Fraction.
 
	erase
	polyfill,[0,fr,fr,0],[0,0,1,1],/norm,col=clr
	textplot,.5,.5,align=[.5,.5],/norm,color=tclr,chars=tsz, $
	  'Seconds left: '+strtrim(round(tleft),2)
 
	wait, 1<tleft
	goto, loop
 
done:	widget_control, top, /dest
 
	end
