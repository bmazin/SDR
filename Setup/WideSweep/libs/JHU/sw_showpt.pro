;-------------------------------------------------------------
;+
; NAME:
;       SW_SHOWPT
; PURPOSE:
;       Scroll a scrolling window to show given point.
; CATEGORY:
; CALLING SEQUENCE:
;       sw_showpt, x, y
; INPUTS:
;       x,y = pixel coordinates of target point.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         WIN=win  Target window (def=current).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Will shift window viewport to just include
;       given point if possible.  May also call for a normal
;       window but no shift is possible.  If point is already in
;       visible area or outside window then no shift is done.
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Jun 13
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro sw_showpt, x, y, win=win0, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Scroll a scrolling window to show given point.'
	  print,' sw_showpt, x, y'
	  print,'   x,y = pixel coordinates of target point.  in'
	  print,' Keywords:'
	  print,'   WIN=win  Target window (def=current).'
	  print,' Notes: Will shift window viewport to just include'
	  print,' given point if possible.  May also call for a normal'
	  print,' window but no shift is possible.  If point is already in'
	  print,' visible area or outside window then no shift is done.'
	  return
	endif
 
	win_save = !d.window			; Save current window.
 
        ;-----  Deal with given window index  -----------
        if n_elements(win0) ne 0 then begin     ; Window index given.
          if win_open(win0) eq 0 then begin
            return
          endif
          if win0 ge 100 then $                 ; scrolling or normal?
            wset,swinfo(win0,/index) $          ; Scrolling window.
          else wset,win0                        ; Normal window.
        endif
 
	s = win_info()				; Get window info.
	if s.win lt 0 then return		; Not a valid window.
	if s.wid lt 0 then return		; Not a scrolling window.
 
	;-----  Determine shift if any  -------------
	dx = 0
	if x gt s.xmx then dx=x-s.xmx
	if x lt s.xmn then dx=x-s.xmn
	dy = 0
	if y gt s.ymx then dy=y-s.ymx
	if y lt s.ymn then dy=y-s.ymn
 
	;----- Do viewport shift ---------------
	widget_control, s.wid, get_draw_view=vw
	widget_control, s.wid, set_draw_view=vw+[dx,dy]
 
	;------  Restore original window  ------
	wset, win_save
 
	end
