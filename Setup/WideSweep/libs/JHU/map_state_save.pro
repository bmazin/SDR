;-------------------------------------------------------------
;+
; NAME:
;       MAP_STATE_SAVE
; PURPOSE:
;       Save last map_set state.
; CATEGORY:
; CALLING SEQUENCE:
;       map_state_save
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
;       map_state_com
; NOTES:
;       Notes: Only one map state may be saved.  Use
;        map_state_restore to restore state.  Useful
;        to preserve map scaling info.
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
	pro map_state_save, help=hlp
 
	common map_state_com, map, x, y
 
	if keyword_set(hlp) then begin
	  print,' Save last map_set state.'
	  print,' map_state_save'
	  print,'   No args.'
	  print,' Notes: Only one map state may be saved.  Use'
 	  print,'  map_state_restore to restore state.  Useful'
	  print,'  to preserve map scaling info.'
	  return
	endif
 
	map = !map
	x = !x
	y = !y
 
	end
