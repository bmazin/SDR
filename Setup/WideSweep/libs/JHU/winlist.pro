;-------------------------------------------------------------
;+
; NAME:
;       WINLIST
; PURPOSE:
;       List windows in use.
; CATEGORY:
; CALLING SEQUENCE:
;       winlist, list
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         FREE=free  Returned list of free windows.
;         PIXLIST=pix Flags for windows in use indicating pixmaps.
;           1 means pixmap, 0 means normal window.
;         /QUIET     Suppress listing.
;         XSIZE=xs, YSIZE=ys  Returned arrays of window sizes.
;         XPOS=xp, YPOS=yp  Returned arrays of window positions.
;         SIZE_MATCH=sz  2 element array with window size to
;           match: [xsize,ysize].  Pixmaps are ignored.
;         WINDOW_MATCH=win Returned index of window with given
;           size (-1=none).
;         LOOKBACK=back  Max number of windows to look back for
;           match.  Default=all.
; OUTPUTS:
;       list = returned list of window numbers in use.  out
; COMMON BLOCKS:
; NOTES:
;       Note: Unless /QUIET used lists window indices and sizes.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Mar 30
;       R. Sterner, 2003 Apr 21 --- Returned window sizes and positions.
;       R. Sterner, 2003 Apr 21 --- Now can return a window matching given size.
;       R. Sterner, 2004 Mar 16 --- Attempt to deal with pixmaps.
;       R. Sterner, 2003 May 13 --- Reversed window list to put latest first.
;       R. Sterner, 2005 Feb 22 --- Listed window IDL code.
;       R. Sterner, 2006 Feb 27 --- Windows help,/recall is different.
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro winlist, list, free=free, quiet=quiet, pixlist=pixlist, $
	  size_match=sz, window_match=win, lookback=back, $
	  xsize=xsize, ysize=ysize, xpos=xpos, ypos=ypos, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' List windows in use.'
	  print,' winlist, list'
	  print,'   list = returned list of window numbers in use.  out'
	  print,' Keywords:'
	  print,'   FREE=free  Returned list of free windows.'
	  print,'   PIXLIST=pix Flags for windows in use indicating pixmaps.'
	  print,'     1 means pixmap, 0 means normal window.'
	  print,'   /QUIET     Suppress listing.'
	  print,'   XSIZE=xs, YSIZE=ys  Returned arrays of window sizes.'
	  print,'   XPOS=xp, YPOS=yp  Returned arrays of window positions.'
	  print,'   SIZE_MATCH=sz  2 element array with window size to'
	  print,'     match: [xsize,ysize].  Pixmaps are ignored.'
	  print,'   WINDOW_MATCH=win Returned index of window with given'
	  print,'     size (-1=none).'
	  print,'   LOOKBACK=back  Max number of windows to look back for'
	  print,'     match.  Default=all.'
	  print,' Note: Unless /QUIET used lists window indices and sizes.'
	  return
	endif
 
	active = !d.window			; Current window.
 
	;----  Lists of used and free windows  ----
	device,window_state=s			; Get window states.
	list = where(s eq 1,n)			; In use windows.
	free = where(s eq 0)			; Available windows.
	if n eq 0 then begin
	  if not keyword_set(quiet) then print,' No windows are open.'
	  win = -1
	  return
	endif
	list = reverse(list)                    ; Latest first.
 
	;---  Deal with pixmaps (determine which windows are pixemaps) ---
	help,/device,output=txt		; Until a better way is found.
	strfind,txt,'Window Status:',index=in,/quiet	; Look for win status.
	if in lt 0 then stop		; No windows.  Should never get here.
	if !version.os_family eq 'Windows' then begin
	  txt = txt(in+1:*)				; Grab only window info.
	  off =12 
	endif else begin
	  txt = txt(in+2:*)				; Grab only window info.
	  off = 8
	endelse
	if !version.os_family eq 'Windows' then begin
	  txt = strmid(txt,0,39)+strmid(txt,39,39)	; 2 columns to 1.
	endif else begin
	  txt = [strmid(txt,0,39),strmid(txt,39,39)]	; 2 columns to 1.
	endelse
	txt = txt(where(txt ne ''))			; Drop null strings.
	pix = s*0					; Pixmap flag array.
	pix_flag = (strmid(txt,off,3) eq 'Pix')		; Pixmap flag values.
	pix(txt+0) = pix_flag		; Fill flag array: 1 if pixmap, else 0.
	pixlist = pix(list)		; Returned pixmap flags.
 
	;-----  Storage for size and positions  ------
	xsize=intarr(n)				; For window sizes
	ysize=intarr(n)				;   and positions.
	xpos=intarr(n)
	ypos=intarr(n)
 
	tprint,/init				; Start output text.
 
	;-----  Loop through used windows getting values  ------
	tprint,' Windows in use, sizes, & lower left corner (from screen llc):'
	for i=0,n-1 do begin			; Loop through windows in use.
	  in = list(i)				; Window number.
	  wset,in				; Set as active.
	  if in eq active then txt=' <-- current' else txt=''
	  xs = !d.x_size			; Size.
	  ys = !d.y_size
	  xsize(i) = xs
	  ysize(i) = ys
	  intxt = ' window, '+strtrim(in,2)
	  if xs lt 10000 then xtxt=strtrim(xs,2) else $
	    xtxt=strtrim(xs,2)
	  if ys lt 10000 then ytxt=strtrim(ys,2) else $
	    ytxt=strtrim(ys,2)
	  if pix(in) then begin			; Window is a pixmap.
	    tprint,intxt+', xsize='+xtxt+', ysize='+$
	      ytxt+', /pixmap  '+txt
	  endif else begin
	    device, get_window_position=pos	; Position.
	    xpos(i) = pos(0)
	    ypos(i) = pos(1)
	    tprint,intxt+', xsize='+xtxt+', ysize='+$
	      ytxt+'   at ('+strtrim(pos(0),2)+', '+strtrim(pos(1),2)+ $
	      ') '+txt
	  endelse
	endfor
 
	;-----  Look for a window of specified size  ------
	if n_elements(sz) ne 0 then begin	; Look for a size match.
	  xs0 = sz(0)				; X size to find.
	  ys0 = sz(1)				; Y size to find.
	  win = -1				; No match yet.
	  if n_elements(back) ne 0 then last=back-1 else last=n-1
	  for i=0,(n-1)<last do begin		; Search through window sizes.
	    if (xs0 eq xsize(i)) and (ys0 eq ysize(i)) then begin
	      if pix(list(i)) eq 0 then begin
	        win = list(i)
	        break
	      endif
	    endif
	  endfor
	endif
 
	;-----  Restore to original window and list results  ------
	wset, active				; Return to entry window.
	if keyword_set(quiet) then return
 
	tprint,/print
 
	end
