;-------------------------------------------------------------
;+
; NAME:
;       WIN_INFO
; PURPOSE:
;       Return a structure with window size and viewport.
; CATEGORY:
; CALLING SEQUENCE:
;       s = win_info([win])
; INPUTS:
;       win = Optional window index (def=current). in
;         For scrolling windows win must be the swindo
;         index, 100 or more.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       s = returned info structure.               out
;         s={xmn:xmn, ymn:ymn,  lower left corner of visible area
;            xmd:xmd, ymd:ymd,  middle of visible area
;            xmx:xmx, ymx:ymx,  upper right corner of visible area
;              dx:dx,   dy:dy,  Size of visible area
;              sx:sx,   sy:sy,  Size of entire window
;              win:win,         Window index.
;              wid:wid}         Widget ID for scrolling window.
; COMMON BLOCKS:
; NOTES:
;       Note: for non-existant window returns win=-1.
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
	function win_info, win0, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Return a structure with window size and viewport.'
	  print,' s = win_info([win])'
	  print,'   win = Optional window index (def=current). in'
	  print,'     For scrolling windows win must be the swindo'
	  print,'     index, 100 or more.'
	  print,'   s = returned info structure.               out'
	  print,'     s={xmn:xmn, ymn:ymn,  lower left corner of visible area'
	  print,'        xmd:xmd, ymd:ymd,  middle of visible area'
	  print,'        xmx:xmx, ymx:ymx,  upper right corner of visible area'
	  print,'          dx:dx,   dy:dy,  Size of visible area'
	  print,'          sx:sx,   sy:sy,  Size of entire window'
	  print,'          win:win,         Window index.'
	  print,'          wid:wid}         Widget ID for scrolling window.'
	  print,' Note: for non-existant window returns win=-1.'
	  return,''
	endif
 
	win_save = !d.window			; Save current window.
 
	;-----  Dealwith given window index  -----------
	if n_elements(win0) ne 0 then begin	; Window index given.
	  if win_open(win0) eq 0 then begin
	    return,{win:-1}
	  endif
	  if win0 ge 100 then $			; scrolling or normal?
	    wset,swinfo(win0,/index) $		; Scrolling window.
	  else wset,win0			; Normal window.
	endif
 
	;-----  Window of interest is now current  ---------
	id = swinfo(/draw)+0L			; Try to get draw wid id.
	if id lt 0 then begin			; Normal window.
	  sx = !d.x_size	; Total window size.
	  sy = !d.y_size
	  dx = sx		; Size of visible area.
	  dy = sy
	  xmn = 0		; LL corner of visible.
	  ymn = 0
	  xmx = sx-1		; UR corner of visible.
	  ymx = sy-1
	  xmd = sx/2		; Middle of visible.
	  ymd = sy/2
	endif else begin
	  g = widget_info(id,/geom)
	  widget_control, id, get_draw_view=vw
	  sx = g.draw_xsize	; Total window size.
	  sy = g.draw_ysize
	  dx = g.xsize		; Size of visible area.
	  dy = g.ysize
	  xmn = vw(0)		; LL corner of visible.
	  ymn = vw(1)
	  xmx = xmn + dx - 1	; UR corner of visible.
	  ymx = ymn + dy - 1
	  xmd = (xmn+xmx)/2	; Middle of visible.
	  ymd = (ymn+ymx)/2
	endelse
 
 
	s = {wid:id, win:!d.window, sx:sx, sy:sy, dx:dx, dy:dy, $
	     xmn:xmn, ymn:ymn, xmx:xmx, ymx:ymx, xmd:xmd, ymd:ymd}
 
	wset,win_save
 
	return, s
 
	end
