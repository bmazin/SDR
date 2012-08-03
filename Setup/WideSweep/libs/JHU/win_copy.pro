;-------------------------------------------------------------
;+
; NAME:
;       WIN_COPY
; PURPOSE:
;       Copies graphics from a hidden window to the target window.
; CATEGORY:
; CALLING SEQUENCE:
;       win_copy
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
;       win_redirect_com
; NOTES:
;       Note: Call WIN_REDIRECT, then do graphics commands.
;       The graphics will be sent to a hidden window.
;       This routine will then move the hidden window to the
;       target window and disable graphics redirection.
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Aug 11
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro win_copy, help=hlp
 
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
	;       flag = 1 if redirection enabled, 0 if not.
	;-----------------------------------------------------------
	common win_redirect_com, tar_num, tar_sx, tar_sy, $
	  max_list, num_list, sx_list, sy_list, cnt_list, $
	  hid_num, counter, flag
 
	if keyword_set(hlp) then begin
	  print,' Copies graphics from a hidden window to the target window.'
	  print,' win_copy'
	  print,'   No arguments.'
	  print,' Note: Call WIN_REDIRECT, then do graphics commands.'
	  print,' The graphics will be sent to a hidden window.'
	  print,' This routine will then move the hidden window to the'
	  print,' target window and disable graphics redirection.'
	  return
	endif
 
	;----------  Check if redirections disabled  -------------
	if flag eq 0 then return
 
	;----------  Make sure win_redirect has been called  -----------
	if n_elements(max_list) eq 0 then begin
	  print,' Error in win_copy: must call win_redirect first.'
	  return
	endif
	if hid_num lt 0 then begin
	  print,' Error in win_copy: must call win_redirect first.'
          return
	endif
 
	;---------  Copy hidden window to target window  ----------------
	wset, tar_num					; Set target as current.
	device, copy=[0,0,tar_sx,tar_sy,0,0,hid_num]	; Do copy.
	hid_num = -1					; Clear hidden window.
	return
 
	end
