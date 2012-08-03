;-------------------------------------------------------------
;+
; NAME:
;       WIN_OPEN
; PURPOSE:
;       Test if a given window is open.
; CATEGORY:
; CALLING SEQUENCE:
;       state = win_open(win)
; INPUTS:
;       win = Window ID to check.   in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       state = state of win:       out
;               0=not open, 1=open.
; COMMON BLOCKS:
; NOTES:
;       Note: If window is open then it is available
;         for use, otherwise it is not.
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Jun 15
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function win_open, win, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Test if a given window is open.'
	  print,' state = win_open(win)'
	  print,'   win = Window ID to check.   in'
	  print,'   state = state of win:       out'
	  print,'           0=not open, 1=open.'
	  print,' Note: If window is open then it is available'
	  print,'   for use, otherwise it is not.'
	  return,''
	endif
 
	if win lt 0 then return, 0B	; Bad window, not open.
 
	device, window_state=wstate	; States of all possible windows.
	last = n_elements(wstate)-1	; Last possible window.
 
	if win gt last then return, 0B	; Bad window, not open.
 
	return, wstate(win)		; Return window state.
 
	end
