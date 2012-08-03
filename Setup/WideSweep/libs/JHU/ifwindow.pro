;-------------------------------------------------------------
;+
; NAME:
;       IFWINDOW
; PURPOSE:
;       Create specified window if it does not exist, else use it.
; CATEGORY:
; CALLING SEQUENCE:
;       ifwindow, in
; INPUTS:
;       in = Index of window to make (def=0).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         XSIZE=nx  X size of requested window (def=current).
;         YSIZE=ny  Y size of requested window (def=current).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: The window index, in, is first tested to see if
;       that window is open.  If not then the window is created.
;       If it is open then the size is tested to see if it matches
;       the requested size.  If not the window is created, else the
;       window is used (wset).
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Jan 09
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ifwindow, in, xsize=nx, ysize=ny, _extra=extra, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Create specified window if it does not exist, else use it.'
	  print,' ifwindow, in'
	  print,'   in = Index of window to make (def=0).  in'
	  print,' Keywords:'
	  print,'   XSIZE=nx  X size of requested window (def=current).'
	  print,'   YSIZE=ny  Y size of requested window (def=current).'
	  print,' Notes: The window index, in, is first tested to see if'
	  print,' that window is open.  If not then the window is created.'
	  print,' If it is open then the size is tested to see if it matches'
	  print,' the requested size.  If not the window is created, else the'
	  print,' window is used (wset).'
	  return
	endif
 
	if n_elements(in) eq 0 then in=0
 
	if win_open(in) then begin		; Window open?
	  winlist,ind,xsize=wxs,ysize=wys,/q	; Check size.
	  ii = (where(ind eq in))(0)
	  if n_elements(nx) eq 0 then nx=wxs(ii)
	  if n_elements(ny) eq 0 then ny=wys(ii)
	  if (wxs(ii) eq nx) and (wys(ii) eq ny) then begin
	    wset, in				; Size OK, use it.
	  endif else begin
	    window,in,xs=nx,ys=ny,_extra=extra	; Wrong size, make new.
	  endelse
	endif else begin
	  window,in,xs=nx,ys=ny,_extra=extra	; Not open, make new.
	endelse
 
	end
