;-------------------------------------------------------------
;+
; NAME:
;       WMENU2
; PURPOSE:
;       Like wmenu but allows non-mouse menus. Uses widgets if available.
; CATEGORY:
; CALLING SEQUENCE:
;       i = wmenu2(list)
; INPUTS:
;       list = menu in a string array.        in
; KEYWORD PARAMETERS:
;       Keywords:
;         TITLE=t  item number to use as title (def = no title).
;         INITIAL_SELECTION=s  initial item selected (=default).
;         /NOMOUSE   forces no mouse mode.
;         /NOWIDGETS forces no widget mode.
; OUTPUTS:
;       i = selected menu item number.        out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 22 May 1990
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function wmenu2, list, title=tt, initial_selection=init, help=hlp, $
	  nomouse=nom, nowidgets=now
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Like wmenu but allows non-mouse menus. Uses widgets if available.'
	  print,' i = wmenu2(list)'
	  print,'   list = menu in a string array.        in'
	  print,'   i = selected menu item number.        out'
	  print,' Keywords:'
	  print,'   TITLE=t  item number to use as title (def = no title).'
	  print,'   INITIAL_SELECTION=s  initial item selected (=default).'
	  print,'   /NOMOUSE   forces no mouse mode.'
	  print,'   /NOWIDGETS forces no widget mode.'
	  return, -1
	endif
 
	if n_elements(tt) eq 0 then tt = -1
	if n_elements(init) eq 0 then init = -1
 
	name = !d.name				; Plot device name.
	flag = 0				; Assume no mouse.
	if name eq 'SUN' then flag = 1		; On SUN, assume mouse.
	if name eq 'X' then flag = 1		; On X windows, assume mouse.
	if keyword_set(nom) then flag = 0	; Force no mouse.
 
	;--------  mouse menu  ----------
	if flag eq 1 then begin
	  if ((!d.flags and 65536) ne 0) and $
	     (not keyword_set(now)) then begin
	    ;-------  Use Widget menu  ---------
	    xmenu, list, base=b, uval=indgen(n_elements(list))
	    widget_control, b, /real
loopw:	    e = widget_event(b)
	    widget_control, e.id, get_uval=in
	    if in eq tt then goto, loopw
	    widget_control, b, /dest
	    return, in
	  endif else begin
	    ;-------  Old style menus  -------
loop:	    in = wmenu(list, title=tt, init=init)
	    if in lt 0 then goto, loop
	    return, in
	  endelse
	endif
 
	;-------  non-mouse menu  --------
	print,' '
	mx = n_elements(list)-1
	if tt ge 0 then print,'          '+list(tt)
	for i = 0, mx do begin
	  if i ne tt then print,' ',i,' '+list(i)
	endfor
loop2:	txt = ''
	if init ge 0 then begin
	  read,' Choose (def = '+strtrim(init,2)+'): ',txt
	endif else begin
	  read,' Choose: ', txt
	endelse
	if txt eq '' then txt = init
	in = txt + 0
	if (in lt 0) or (in gt mx) then begin
	  print,' You must choose one of the above'
	  goto, loop2
	endif
	if in eq tt then begin
	  print,' You must choose one of the above'
	  goto, loop2
	endif
	return, in
 
	end
