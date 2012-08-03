;-------------------------------------------------------------
;+
; NAME:
;       WINWATCH
; PURPOSE:
;       Zoom part of the current window in a display window.
; CATEGORY:
; CALLING SEQUENCE:
;       winwatch, in
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /INIT means select area to zoom.
;         MAG=mag Set zoom mag factor on /INIT (def=5).
;         /CLEANUP Remove the zoom window.
;         /NOOUTLINE Do not outline watch window in input window.
;         COLOR=clr Outline color.
;         TITLE=tt Watch window title (/INIT only).
;         /SAVE save the contents of the watch windows after
;           they are updated.  They are saved as PNGs with the title
;           and a count as the names.
;         /RESET_COUNTERS will reset save count for each window
;           so the next save will start at 001, then returns.
;         GET=s_out  Get internal state in a structure and return.
;         SET=s_in   Set internal state from a structure and return.
;           Sets only those values given in the structure.
;           May set fewer than 10 values but not more.
;         ARRAY=arr  Give array corresponding to full displayed
;           image, statistics will be listed for each subimage.
; OUTPUTS:
; COMMON BLOCKS:
;       winwatch_com
; NOTES:
;       Notes: Call this routine after graphics commands to
;       display a part of the window zoomed in a display window.
;       Can change the area any time by calling winwatch,ind,/init.
;       Add a call to winwatch at the end of a command to make
;       it easy to use the up arrow to repeat commands.
;       Internal state structure:
;         All items are 10 element arrays (up to 10 watch windows).
;         flag[i]: 1 if watch window i is in use, else 0.
;         win_in[i]: Input window index for watch window i.
;         win_out[i]: window index of watch window i.
;         mag[i]: Mag factor for watch window i.
;         x1[i], y1[i]: Subarea start pixel for watch window i.
;         dx[i], dy[i]: Subarea x and y size for watch window i.
;         sv_cnt[i]: Save count for watch window i.
;         sv_nam[i]: Base name of saved image for watch window i.
; MODIFICATION HISTORY:
;       R. Sterner, 2007 Jan 23
;       R. Sterner, 2007 Feb 08 --- Allowed multiple watch windows.
;       Also may give multiple windows as an array.  Default for
;       display or cleanup are all initialized windows.  Added
;       window titles.  Now may save windows.
;       R. Sterner, 2007 Feb 09 --- Checks that window exists before deleting.
;       Added /reset_counters.
;       R. Sterner, 2007 Feb 12 --- Added GET and SET.
;       R. Sterner, 2007 Feb 12 --- Recreated watch windows when needed.
;       R. Sterner, 2007 Feb 23 --- Fixed default watch win for /init.
;       R. Sterner, 2007 Apr 03 --- Added new keyword ARRAY=arr.
;       R. Sterner, 2007 Apr 05 --- Switched to keyword NOOUTLINE.
;
; Copyright (C) 2007, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro winwatch, in0, init=init, mag=mag0, cleanup=cleanup, $
	  nooutline=nooutline, color=clr, title=ttl0, save=save, $
	  reset_counters=reset, get=s_out, set=s_in, help=hlp, $
	  array=array
	  
 
	common winwatch_com, flag, win_in, win_out, mag, $
	  x1,y1, dx,dy, sv_cnt, sv_nam
	;------------------------------------------------------------
	;  flag = Window in use flag: 0=no, 1=yes.
	;  win_in = Input window index (current window when called).
	;  win_out = Watch window index.
	;  mag = Watch window mag factor.
	;  x1,y1 = Watch area lower left corner.
	;  dx,dy = Watch area x and y size.
	;  sv_cnt = How many times window has been saved.
	;  sv_nam = Base name of saved image (= title).
	;------------------------------------------------------------
 
	if keyword_set(hlp) then begin
	  print,' Zoom part of the current window in a display window.'
	  print,' winwatch, in'
	  print,'   in = Watch window index or array (0 to 9, def=0).'
	  print,'     The default is an array of all initialized watch'
	  print,'     windows except on /INIT where they must be given.'
	  print,' Keywords:'
	  print,'   /INIT means select area to zoom.'
	  print,'   MAG=mag Set zoom mag factor on /INIT (def=5).'
	  print,'   /CLEANUP Remove the zoom window.'
	  print,'   /NOOUTLINE Do not outline watch window in input window.'
	  print,'   COLOR=clr Outline color.'
	  print,'   TITLE=tt Watch window title (/INIT only).'
	  print,'   /SAVE save the contents of the watch windows after'
	  print,'     they are updated.  They are saved as PNGs with the title'
	  print,'     and a count as the names.'
	  print,'   /RESET_COUNTERS will reset save count for each window'
	  print,'     so the next save will start at 001, then returns.'
	  print,'   GET=s_out  Get internal state in a structure and return.'
	  print,'   SET=s_in   Set internal state from a structure and return.'
	  print,'     Sets only those values given in the structure.'
	  print,'     May set fewer than 10 values but not more.'
	  print,'   ARRAY=arr  Give array corresponding to full displayed'
	  print,'     image, statistics will be listed for each subimage.'
	  print,' Notes: Call this routine after graphics commands to'
	  print,' display a part of the window zoomed in a display window.'
	  print,' Can change the area any time by calling winwatch,ind,/init.'
	  print,' Add a call to winwatch at the end of a command to make'
	  print,' it easy to use the up arrow to repeat commands.'
	  print,' Internal state structure:'
	  print,'   All items are 10 element arrays (up to 10 watch windows).'
	  print,'   flag[i]: 1 if watch window i is in use, else 0.'
	  print,'   win_in[i]: Input window index for watch window i.'
	  print,'   win_out[i]: window index of watch window i.'
	  print,'   mag[i]: Mag factor for watch window i.'
	  print,'   x1[i], y1[i]: Subarea start pixel for watch window i.'
	  print,'   dx[i], dy[i]: Subarea x and y size for watch window i.'
	  print,'   sv_cnt[i]: Save count for watch window i.'
	  print,'   sv_nam[i]: Base name of saved image for watch window i.'
	  return
	endif
 
	;------------------------------------------
	;  Initialize the common
	;------------------------------------------
	if n_elements(flag) eq 0 then begin
	  flag = bytarr(10)
	  win_in = intarr(10)
	  win_out = intarr(10)
	  mag = intarr(10)
	  x1 = intarr(10)
	  y1 = intarr(10)
	  dx = intarr(10)
	  dy = intarr(10)
	  sv_cnt = intarr(10)
	  sv_nam = strarr(10)
	endif
 
	;------------------------------------------
	;  Get internal state
	;------------------------------------------
	if arg_present(s_out) then begin
	  s_out = {flag:flag, win_in:win_in, win_out:win_out, $
	     mag:mag, x1:x1, y1:y1, dx:dx, dy:dy, $
	     sv_cnt:sv_cnt, sv_nam:sv_nam } 
	  return
	endif
 
	;------------------------------------------
	;  Set internal state
	;------------------------------------------
	if n_elements(s_in) ne 0 then begin
	  if tag_test(s_in,'flag')    then flag[0]    = s_in.flag
	  if tag_test(s_in,'win_in')  then win_in[0]  = s_in.win_in
	  if tag_test(s_in,'win_out') then win_out[0] = s_in.win_out
	  if tag_test(s_in,'mag')     then mag[0]     = s_in.mag
	  if tag_test(s_in,'x1')      then x1[0]      = s_in.x1
	  if tag_test(s_in,'y1')      then y1[0]      = s_in.y1
	  if tag_test(s_in,'dx')      then dx[0]      = s_in.dx
	  if tag_test(s_in,'dy')      then dy[0]      = s_in.dy
	  if tag_test(s_in,'sv_cnt')  then sv_cnt[0]  = s_in.sv_cnt
	  if tag_test(s_in,'sv_nam')  then sv_nam[0]  = s_in.sv_nam
	  return
	endif
 
	;------------------------------------------
	;  Reset counters
	;------------------------------------------
	if keyword_set(reset) then begin
	  sv_cnt = 0*sv_cnt
	  print,' Winwatch save counters reset.'
	  return
	endif
 
	;------------------------------------------
	;  Initialize a watch window
	;------------------------------------------
	if keyword_set(init) then begin
	  if n_elements(in0) eq 0 then in0=0	; Default watch win is 0.
	  wshow
	  if n_elements(ttl0) eq 0 then begin	; Default window titles.
	    ttl0 = 'win_'+string(in0,form='(I1)')
	  endif
	  lst_tt = n_elements(ttl0)-1		; # titles given.
	  if n_elements(in0) eq 0 then in0=0	; Default watch window index.
	  for j=0,n_elements(in0)-1 do begin	; Loop over requested windows.
	    in = in0[j]				; Requested window.
	    xmess,['Drag open a watch box in current window',$
	           'for '+ttl0[j<lst_tt]], $
	      /nowait,wid=wid,yoff=100
	    box2b,/stat,x10,x2,y10,y2,ex=ex	; Interactive box.
	    widget_control, wid, /destroy	; Remove message widget.
	    if ex ne 0 then break		; Aborted.
	    x1[in] = x10
	    y1[in] = y10
	    dx[in] = x2-x1[in]+1		; Box size.
	    dy[in] = y2-y1[in]+1
	    win_in[in] = !d.window		; Input window.
	    img = tvrd(x1[in],y1[in],dx[in],dy[in],tr=3) ; Read subimage.
	    if not keyword_set(nooutline) then begin
	      if n_elements(clr) eq 0 then clr=!p.color
	      ix1=x1[in] & iy1=y1[in] & ix2=ix1+dx[in]-1 & iy2=iy1+dy[in]-1
	      plots,/dev,[ix1,ix2,ix2,ix1,ix1],[iy1,iy1,iy2,iy2,iy1],col=clr
	    endif
	    if n_elements(mag0) eq 0 then mag0=5  ; Set mag factor.
	    mag[in] = mag0			; Save in common.
	    xs = dx[in]*mag[in]			; Output window size.
	    ys = dy[in]*mag[in]
	    if flag[in] eq 1 then begin
	      if win_open(win_out[in]) then begin
	        wdelete, win_out[in] ; Delete old win if any.
	      endif
	    endif
	    winlist,/quiet,free=free
	    nxt = min(free(where(free ge 32)))
	    ttl = ttl0[j<lst_tt]		; Window title.
	    sv_nam[in] = repchr(ttl,' ','_')	; Update save file base name.
	    tt = ttl + '  ' + strtrim(nxt,2)	; Add window index to title.
	    window,/free,xs=xs,ys=ys,titl=tt	; Output window.
	    win_out[in] = !d.window		; Save in common.
	    img = img_resize(img,mag=mag[in],/rebin,/samp) ; Resize subimage.
	    tv,img,tr=3				; Display subimage.
	    wset, win_in[in]			; Set back to input window.
	    flag[in] = 1			; Set initialized flag.
	  endfor
	  return
	endif
 
	;------------------------------------------
	;  Cleanup
	;------------------------------------------
	if keyword_set(cleanup) then begin
	  if n_elements(in0) eq 0 then in0=where(flag eq 1)
	  for j=0,n_elements(in0)-1 do begin
	    in = in0[j]			; Requested window.
	    if flag[in] eq 1 then begin
	      if win_open(win_out[in]) then begin
	        wdelete, win_out[in]
	      endif
	      if win_open(win_in[in]) then wset, win_in[in]
	      flag[in] = 0
	      sv_cnt[in] = 0
	    endif
	  endfor ; j
	  return
	endif
 
	;------------------------------------------
	;  Update watch window
	;------------------------------------------
	win_cur = !d.window		; Current window.
	if n_elements(in0) eq 0 then begin
	  in0 = where(flag eq 1, cnt)
	  if cnt eq 0 then return
	endif
	;---  Loop over watch windows  ---
	for j=0,n_elements(in0)-1 do begin
	  in = in0[j]			; Requested window.
	  if flag[in] eq 0 then begin
	    print,' Must do winwatch,/init first for watch window ',in
	    continue
	  endif
	  ;---  Read from input window  ---
	  wset, win_in[in]		; Set to input window.
	  img = tvrd(x1[in],y1[in],dx[in],dy[in],tr=3) ; Read subimage.
	  if not keyword_set(nooutline) then begin
	    if n_elements(clr) eq 0 then clr=!p.color
	    ix1=x1[in] & iy1=y1[in] & ix2=ix1+dx[in]-1 & iy2=iy1+dy[in]-1
	    plots,/dev,[ix1,ix2,ix2,ix1,ix1],[iy1,iy1,iy2,iy2,iy1],col=clr
	  endif
	  ;---  Display subarea in watch window  ---
	  img = img_resize(img,mag=mag[in],/rebin,/samp)     ; Resize.
	  if not win_open(win_out[in]) then begin  ; Recreate watch win?
	    winlist,/quiet,free=free		; Find all free windows.
	    nxt = min(free(where(free ge 32)))	; Next free window.
	    ttl = sv_nam[in]			; Window title.
	    tt = ttl + '  ' + strtrim(nxt,2)	; Add window index to title.
	    xs = dx[in]*mag[in]			; Output window size.
	    ys = dy[in]*mag[in]
	    window,/free,xs=xs,ys=ys,titl=tt	; Output window.
	    win_out[in] = !d.window		; Save in common.
	  endif
	  wset, win_out[in]		; Set to output window.
	  tv,img,tr=3			; Display subimage.
	  wshow
	  ;---  List subimage statistics  -------
	  if n_elements(array) ne 0 then begin
	    ix1=x1[in] & iy1=y1[in] & ix2=ix1+dx[in]-1 & iy2=iy1+dy[in]-1
	    sub = array[ix1:ix2,iy1:iy2]
	    print,' '+sv_nam[in]+': Mean='+strtrim(mean(sub),2)+ $
	      ', Min='+strtrim(min(sub),2)+ $
	      ', Max='+strtrim(max(sub),2)+ $
	      ', SD='+strtrim(sdev(sub),2)
	  endif
	  ;---  Save watch window  ---
	  if keyword_set(save) then begin
	    sv_cnt[in] += 1		; Inc save counter.
	    png = sv_nam[in]+'_'+string(sv_cnt[in],form='(I3.3)')+'.png'
	    pngscreen,png		; Save.
	  endif
	endfor ; j
	wset, win_cur			; Set back to incoming window.
	return
 
	end
