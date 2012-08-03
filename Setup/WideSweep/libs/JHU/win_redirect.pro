;-------------------------------------------------------------
;+
; NAME:
;       WIN_REDIRECT
; PURPOSE:
;       Redirects all graphics to a hidden window.
; CATEGORY:
; CALLING SEQUENCE:
;       win_redirect
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /STATUS lists available hidden windows and sizes.
;         /CLEANUP deletes all hidden windows.
;         /OFF means disable window redirection.
;         /ON means enable window redirection (default).
;           Turning off redirection is an easy way to see the
;           effects of redirection.
; OUTPUTS:
; COMMON BLOCKS:
;       win_redirect_com
; NOTES:
;       Note: resets from current window to new hidden window
;       of same size.  All graphics following go to the hidden
;       window.  Use WIN_COPY to move the hidden window to the
;       target window and disable graphics redirection.
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Aug 11
;       R. Sterner, 1999 Aug 16 --- Added disable/enable options.
;       R. Sterner, 2007 Feb 22 --- On /cleanup check if window is open 1st.
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro win_redirect, status=status, cleanup=cleanup, $
	  on=on, off=off, help=hlp
 
	;-----------------------------------------------------------
	;  Window redirection common:
	;	tar_num = Target window ID (= current window).
	;	tar_sx, tar_sy = target window size.
	;	max_list = Size of hidden window list.
	;	num_list = list of available hidden window IDs.
	;	sx_list, sy_list = Sizes of available hidden windows.
	;	cnt_list = list of last counter values for each hid win.
	;	hid_num = ID of hidden window used.
	;	counter = routine call counter.  Used as a timer to
	;	  find least used hidden windows for replacement.
	;	flag = 1 if redirection enabled, 0 if not.
	;-----------------------------------------------------------
	common win_redirect_com, tar_num, tar_sx, tar_sy, $
	  max_list, num_list, sx_list, sy_list, cnt_list, $
	  hid_num, counter, flag
 
	if keyword_set(hlp) then begin
	  print,' Redirects all graphics to a hidden window.'
	  print,' win_redirect'
	  print,'   No arguments.'
	  print,' Keywords:'
	  print,'   /STATUS lists available hidden windows and sizes.'
	  print,'   /CLEANUP deletes all hidden windows.'
	  print,'   /OFF means disable window redirection.'
	  print,'   /ON means enable window redirection (default).'
	  print,'     Turning off redirection is an easy way to see the'
	  print,'     effects of redirection.'
	  print,' Note: resets from current window to new hidden window'
	  print,' of same size.  All graphics following go to the hidden'
	  print,' window.  Use WIN_COPY to move the hidden window to the'
	  print,' target window and disable graphics redirection.'
	  return
	endif
 
	;----------  Initialize common first time  ------------------
	if n_elements(max_list) eq 0 then begin
	  max_list = 10			; Max number of windows to keep.
	  num_list = lonarr(max_list)	; Hidden window IDs.
	  sx_list  = lonarr(max_list)	; Hidden window X sizes (0=not used).
	  sy_list  = lonarr(max_list)	; Hidden window Y sizes.
	  cnt_list = lonarr(max_list)	; Last used (= routine call count).
	  hid_num  = -1L		; Current active hidden window ID.
	  counter  = 0L			; Routine call counter.
	  flag = 1			; Enable flag (1=yes).
	endif
 
	;----------  Disable or enable window redirection  ------------
	if keyword_set(off) then begin flag=0 & return & endif
	if keyword_set(on)  then begin flag=1 & return & endif
 
	;----------  Hidden window status  --------------------------
	if keyword_set(status) then begin
	  print,' '
	  print,' Window redirection hidden windows status'
	  print,' '
	  print,' Redirection is turned '+(['off','on'])(flag)
	  w = where(sx_list gt 0, cnt)
	  print,' Max different windows possible: '+strtrim(max_list,2)+ $
	    '.   Number used: '+strtrim(cnt,2)
	  print,' Current window ID: '+strtrim(!d.window,2)+'.  '+$
	    'Current counter: '+strtrim(counter,2)
	  w = where(!d.window eq num_list, cnt)
	  if !d.window lt 32 then cnt=0
	  if cnt gt 0 then print,' >>>===> Current window is a hidden window.'
	  for i=0,max_list-1 do begin
	    if sx_list(i) gt 0 then begin
	      print,'    Hidden window '+strtrim(i,2)+' ID = '+ $
		strtrim(num_list(i),2)+ $
	    	'.   Size (x,y) = '+strtrim(sx_list(i),2)+ $
		', '+strtrim(sy_list(i),2)+ $
	    	'.   Last accessed at '+strtrim(cnt_list(i),2)
	    endif
	  endfor
	  return
	endif
 
	;----------  Check if redirection enabled  ------------------
	if flag eq 0 then return
 
	;----------  Cleanup hidden windows  ------------------------
	if keyword_set(cleanup) then begin
	  for i=0,max_list-1 do begin		; Delete all windows in list.
	    if sx_list(i) gt 0 then begin	; If window exists.
	      if win_open(num_list(i)) then wdelete,num_list(i)	; Delete window.
	      sx_list(i)  = 0			; Clear out list.
	      sy_list(i)  = 0
	      cnt_list(i) = 0
	    endif
	  endfor
	  hid_num  = -1L		; Current active hidden window ID.
	  counter  = 0L			; Routine call counter.
	  return
	endif
 
	;----------  Count each call of this routine  ------------------
	counter = counter + 1
 
	;----------  Grab current window and its size  -----------------
	tar_num = !d.window		; Current window ID.
	tar_sx  = !d.x_size		; Current window X size.
	tar_sy  = !d.y_size		; Current window Y size.
 
	;----------  Look for a hidden window of the same size  --------
	w = where((tar_sx eq sx_list) and (tar_sy eq sy_list), cnt)
 
	;----------  Have a window of the right size  ------------------
	if cnt gt 0 then begin
	  in = w(0)			; Index of matching window.
	  hid_num = num_list(in)	; Hidden window ID.
	  cnt_list(in) = counter	; This window last used at this count.
	  wset, hid_num			; Set hidden window to be current.
	  return			; All done.
	endif
 
	;---------  Need to make a new window  -------------------------
	w = where(cnt_list eq min(cnt_list))	; Replace oldest window.
	in = w(0)				; Index of oldest window.
	;---------  Window exists, need to resize it  -----------
	if sx_list(in) gt 0 then begin
	  hid_num = num_list(in)	; Window ID.
	  wdelete,hid_num		; Delete old window.
	  window,/free,xs=tar_sx,ys=tar_sy,/pix	; New window.
	  hid_num = !d.window		; Window ID.
	  num_list(in) = hid_num	; Save in list.
	  sx_list(in) = tar_sx		; Remember window size.
	  sy_list(in) = tar_sy
	  cnt_list(in) = counter	; This window last used at this count.
	  return			; All done.
	;---------  Window does not exist, need to create it  -----------
	;  Note: existing window must be deleted first, can't create
	;  window numbers 32 and up directly, only through /free.
	endif else begin
	  window,/free,xs=tar_sx,ys=tar_sy,/pix		; New window.
	  hid_num = !d.window		; Remember window ID.
	  num_list(in) = hid_num	; Remember window ID.
	  sx_list(in) = tar_sx		; Remember window size.
	  sy_list(in) = tar_sy
	  cnt_list(in) = counter	; This window last used at this count.
	  return			; All done.
	endelse
 
	end
