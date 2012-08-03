;-------------------------------------------------------------
;+
; NAME:
;       XORPLOT
; PURPOSE:
;       Manage XOR plots.  Erases last when plotting new.
; CATEGORY:
; CALLING SEQUENCE:
;       xorplot
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         X=x, Y=y  X and Y arrays to plot.  in
;           X is optional.
;        /INIT means do not erase last curve on next call.
; OUTPUTS:
; COMMON BLOCKS:
;       xorplot_com
; NOTES:
;       Note: Will plot given data and save it.  On next call
;       will replot the old data first to erase it, then the new.
;       Sets XOR plot mode internally.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jul 29
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro xorplot, x=x, y=y, init=init, help=hlp
 
	common xorplot_com, xlst, ylst, flag, mode, last
 
	if keyword_set(hlp) then begin
	  print,' Manage XOR plots.  Erases last when plotting new.'
	  print,' xorplot'
	  print,'  All args are keywords.'
	  print,' Keywords:'
	  print,'   X=x, Y=y  X and Y arrays to plot.  in'
	  print,'     X is optional.'
	  print,'  /INIT means do not erase last curve on next call.'
	  print,' Note: Will plot given data and save it.  On next call'
	  print,' will replot the old data first to erase it, then the new.'
	  print,' Sets XOR plot mode internally.'
	  return
	endif
 
	;-------  Initialize  -----------------------------
	if keyword_set(init) then last=0		; Don't erase next call.
	if n_elements(y) eq 0 then return		; Nothing to plot.
 
	if n_elements(flag) eq 0 then flag=-1		; Set flag to init.
	if flag lt 0 then begin
	  if !d.name eq 'X' then flag=1 else flag=0	; Plot device flag.
	  mode = 0
	  if flag eq 1 then device,get_graphics=mode	; Mode to restore.
	  last = 0					; No last plot.
	endif
 
	;-------  Go into XOR mode  ------------------------
	if flag then device,set_graphics=6	; XOR mode.
 
	;-------  Make sure X defined  ---------------------
	if n_elements(x) eq 0 then x=findgen(n_elements(y))
 
	;-------  Erase last plot  -------------------------
	if last then begin
	  oplot, xlst, ylst
	  empty
	endif
 
	;-------  Plot new  --------------------------------
	oplot,x,y
	xlst = x
	ylst = y
	last = 1
	empty
 
	;-------  Return to entry mode  ---------------------
	if flag then device,set_graphics=mode	; XOR mode.
 
	end
