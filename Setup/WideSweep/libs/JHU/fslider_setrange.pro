;-------------------------------------------------------------
;+
; NAME:
;       FSLIDER_SETRANGE
; PURPOSE:
;       Set new min/max for cw_fslider.
; CATEGORY:
; CALLING SEQUENCE:
;       fslider_setrange, id, min, max, val
; INPUTS:
;       id = widget id of cw_fslider to modify.   in
;       min = New minimum value (def=0.).         in
;       max = New maximum value (def=100.).       in
;       val = New slider value (def=(min+max)/2). in
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: new value is set to update slider
;         position and labeled value.
; MODIFICATION HISTORY:
;       R. Sterner, 1998 Jun 10
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro fslider_setrange, id, min, max, val, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Set new min/max for cw_fslider.'
	  print,' fslider_setrange, id, min, max, val'
	  print,'   id = widget id of cw_fslider to modify.   in'
	  print,'   min = New minimum value (def=0.).         in'
	  print,'   max = New maximum value (def=100.).       in'
	  print,'   val = New slider value (def=(min+max)/2). in'
	  print,' Note: new value is set to update slider'
	  print,'   position and labeled value.'
	  return
	endif
 
	;------  Set defaults  ---------------
	if n_elements(min) eq 0 then min=0.
	if n_elements(max) eq 0 then max=100.
	if n_elements(val) eq 0 then val=(min+max)/2.
 
	;------  Update slider  --------------
        c = widget_info(id,/child)              ; First child of cw_fslider.
        widget_control, c, get_uval=state       ; Grab state structure.
        state.bot = min                         ; Set new min and max.
        state.top = max
        widget_control, c, set_uval=state       ; Store updated state.
        widget_control, id, set_val=val         ; Set val to update slider.
 
        end
