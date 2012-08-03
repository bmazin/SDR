;-------------------------------------------------------------
;+
; NAME:
;       DECOMPOSE
; PURPOSE:
;       Device independent decompose set or get.
; CATEGORY:
; CALLING SEQUENCE:
;       decompose
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         SET=d Set new decompose value.
;         GET=d Get current decompose value.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: the DEVICE procedure will give an error if used
;         for devices where decomposed does not apply.  This
;         routine quietly does something without halting.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jun 25
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro decompose, set=set, get=get, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Device independent decompose set or get.'
	  print,' decompose'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   SET=d Set new decompose value.'
	  print,'   GET=d Get current decompose value.'
	  print,' Note: the DEVICE procedure will give an error if used'
	  print,'   for devices where decomposed does not apply.  This'
	  print,'   routine quietly does something without halting.'
	  return
	endif
 
	;-------  Check if decomposed is available  ---------
	dflag = 0			  ; Is decompose available?  Start no.
	if !d.name eq 'X' then dflag=1	  ; Yes, decomp compatible.
	if !d.name eq 'MAC' then dflag=1  ; Yes, decomp compatible.
	if !d.name eq 'WIN' then dflag=1  ; Yes, decomp compatible.
 
	;-------  Get current value of decomposed  -----------
	if dflag eq 1 then device, get_decomp=get else get=-1
 
	;-------  Set new value of decomposed  -----------
	if dflag eq 1 then device, decomp=set
 
	end
