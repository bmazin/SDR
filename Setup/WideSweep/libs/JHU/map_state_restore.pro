;-------------------------------------------------------------
;+
; NAME:
;       MAP_STATE_RESTORE
; PURPOSE:
;       Restore last map_set state.
; CATEGORY:
; CALLING SEQUENCE:
;       map_state_restore
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
;       map_state_com
; NOTES:
;       Notes: use after map_state_save to restore
;       map scaling info.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Dec 30
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro map_state_restore, help=hlp
 
	common map_state_com, map, x, y
 
	if keyword_set(hlp) then begin
	  print,' Restore last map_set state.'
	  print,' map_state_restore'
	  print,'   No args.'
	  print,' Notes: use after map_state_save to restore'
 	  print,' map scaling info.'
	  return
	endif
 
	!map = map
	!x = x
	!y = y
 
	end
