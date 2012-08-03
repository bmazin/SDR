;-------------------------------------------------------------
;+
; NAME:
;       SWINFO
; PURPOSE:
;       Return info for current or specified scrolling window.
; CATEGORY:
; CALLING SEQUENCE:
;       out = swinfo([index])
; INPUTS:
;       index = optional window index (def=current window).  in
;         index may be scrolling window index (>100)
;         or ordinary window index (<100).
;       out = Returned value. -1 means not a valid window.
; KEYWORD PARAMETERS:
;       Keywords:
;         /INDEX return IDL window index.
;         /SWINDEX return scrolling window index.
;         /SIZE full window size [sx,sy].
;         /VISIBLE size of visible part of window [vx,vy].
;         /TITLE swindow title.
;         /BASE swindow base widget ID.
;         /DRAW swindow draw widget ID.
;         /EXISTS Does window exist? 0=no, 1=yes.
;         /VIEW=vw 2-elements array with pixel x,y of lower left window corner.
;             Can use to find or mark window center:
;             plots,/dev,psym=2,col=255,swinfo(/view)+swinfo(/vis)/2
; OUTPUTS:
; COMMON BLOCKS:
;       swindow_com
; NOTES:
;       Note: only one keyword is allowed in a call.
;         Useful for scrolling a scroll window. Example:
;           widget_control,swinfo(101,/draw),set_draw=[50,60]
;         See also: swindow, swdelete, swlist.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Aug 14
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function swinfo, ind0, help=hlp, index=index, swindex=swindex, $
	  size=sz, visible=vis, title=ttl, base=bas, draw=drw, exists=ex, $
	  view=vw
 
        common swindow_com, indx, base, sw_ind, swcnt, $
          sw_titl, sw_fx, sw_fy, sw_vx, sw_vy, drw_wid
        ;-------------------------------------------------------------
        ;  Scrolling windows common (only for scrolling windows):
        ;    indx = array of window numbers to be used by wset.
        ;    base = array of window widget base numbers.
        ;    swcnt = Current count of scrolling windows.
        ;    sw_titl = array of window titles.
        ;    sw_ind = array of window numbers as seen by user (100+).
        ;    sw_fx = array of window full x sizes.
        ;    sw_fy = array of window full y sizes.
        ;    sw_vx = array of window visible x sizes.
        ;    sw_vy = array of window visible y sizes.
        ;    drw_wid = array of draw widget IDs.
        ;--------------------------------------------------------------
 
	if keyword_set(hlp) then begin
	  print,' Return info for current or specified scrolling window.'
	  print,' out = swinfo([index])'
	  print,'   index = optional window index (def=current window).  in'
	  print,'     index may be scrolling window index (>100)'
	  print,'     or ordinary window index (<100).'
	  print,'   out = Returned value. -1 means not a valid window.'
	  print,' Keywords:'
	  print,'   /INDEX return IDL window index.'
	  print,'   /SWINDEX return scrolling window index.'
	  print,'   /SIZE full window size [sx,sy].'
	  print,'   /VISIBLE size of visible part of window [vx,vy].'
	  print,'   /TITLE swindow title.'
	  print,'   /BASE swindow base widget ID.'
	  print,'   /DRAW swindow draw widget ID.'
	  print,'   /EXISTS Does window exist? 0=no, 1=yes.'
	  print,'   /VIEW=vw 2-elements array with pixel x,y of lower left window corner.'
	  print,'       Can use to find or mark window center:'
	  print,'       plots,/dev,psym=2,col=255,swinfo(/view)+swinfo(/vis)/2'
	  print,' Note: only one keyword is allowed in a call.'
	  print,'   Useful for scrolling a scroll window. Example:'
	  print,'     widget_control,swinfo(101,/draw),set_draw=[50,60]'
	  print,'   See also: swindow, swdelete, swlist.'
	  return,''
	endif
 
	;------  No window index given, use current window  -----
	if n_elements(ind0) ne 0 then ind = ind0	; Copy.
	if n_elements(ind) eq 0 then ind = !d.window	; Use default.
	if ind lt 0 then return,-1			; No current window.
	if n_elements(indx) eq 0 then begin		; No scroll windows.
	  return, -1
	endif
 
	;------  Look for window index in tables  -------
	if ind lt 100 then begin		; Index was IDL index.
	  w = where(indx eq ind, cnt)
	endif else begin			; Index was swindow index.
	  w = where(sw_ind eq ind, cnt)
	  if cnt gt 0 then ind = indx(w(0))	; Want IDL window index.
	endelse
	iw = w(0)
 
	;------  Window not found  -----------
	if cnt eq 0 then return, -1
 
	;------  Grab requested value  -----------
	val = -1
	if keyword_set(index) then val=indx(iw)
	if keyword_set(swindex) then val=sw_ind(iw)
	if keyword_set(sz) then val=[sw_fx(iw),sw_fy(iw)]
	if keyword_set(vis) then val=[sw_vx(iw),sw_vy(iw)]
	if keyword_set(ttl) then val=sw_titl(iw)
	if keyword_set(bas) then val=long(base(iw))
	if keyword_set(drw) then val=drw_wid(iw)
	if keyword_set(ex) then val=win_open(ind)
	if keyword_set(vw) then widget_control, drw_wid(iw), get_draw_view=val
 
	return, val
 
	end
