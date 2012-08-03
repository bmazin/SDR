;-------------------------------------------------------------
;+
; NAME:
;       GET_VISUAL_NAME
; PURPOSE:
;       Device independent get_visual_name.
; CATEGORY:
; CALLING SEQUENCE:
;       get_visual_name, vis
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       vis = returned visual class name.   out
; COMMON BLOCKS:
; NOTES:
;       Note: the DEVICE procedure will give an error if used
;         for devices where get_visual_name does not apply.  This
;         routine quietly does something without halting.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jun 25'
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro get_visual_name, vis, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Device independent get_visual_name.'
	  print,' get_visual_name, vis''
	  print,'   vis = returned visual class name.   out'
	  print,' Note: the DEVICE procedure will give an error if used'
	  print,'   for devices where get_visual_name does not apply.  This'
	  print,'   routine quietly does something without halting.'
	  return
	endif
 
	;-------  Check if decomposed is available  ---------
	vflag = 0			  ; Is visual name available?  Start no.
	if !d.name eq 'X' then vflag=1	  ; Yes.
	if !d.name eq 'MAC' then vflag=1  ; Yes.
	if !d.name eq 'WIN' then vflag=1  ; Yes.
 
	;-------  Get visual name  -----------
	if vflag eq 1 then device, get_visual_name=vis else vis=''
 
	;-------  Z Buffer is a special case  -----------
	if !d.name eq 'Z' then vis='PseudoColor'
 
	end
