;-------------------------------------------------------------
;+
; NAME:
;       CGM
; PURPOSE:
;       Toggles graphics redirection to a *.cgm file on or off.
; CATEGORY:
; CALLING SEQUENCE:
;       cgm, [file]
; INPUTS:
;       file = optional cgm file name.   in
;         Default file name is seconds after midnight, like
;         31412.cgm.
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
;       cgm
; NOTES:
;       Notes: Computer Graphics Metafile (CGM) format files are
;         useful because they may be imported into word processor
;         documents.  An initial color table warning message appears
;         to be harmless.
; MODIFICATION HISTORY:
;       R. Sterner 2 Dec, 1992
;       R. Sterner, 29 Jan, 1993 --- Revised.
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
  	pro cgm, file0, help=hlp
 
	common cgm, cgmflag, dev, file
 
	if keyword_set(hlp) then begin
	  print,' Toggles graphics redirection to a *.cgm file on or off.'
	  print,' cgm, [file]'
	  print,'   file = optional cgm file name.   in'
	  print,'     Default file name is seconds after midnight, like'
	  print,'     31412.cgm.'
	  print,' Notes: Computer Graphics Metafile (CGM) format files are'
	  print,'   useful because they may be imported into word processor'
	  print,'   documents.  An initial color table warning message appears'
	  print,'   to be harmless.'
	  return
	endif
 
	if n_elements(cgmflag) eq 0 then cgmflag = 0	; Start cgm off.
 
	if cgmflag eq 0 then begin			; Was off, turn on.
	  if n_elements(file0) eq 0 then begin		; Def. file name = sec
	    dt_tm_brk, systime(), dt, tm		;   after midnight.
	    file0 = strtrim(long(secstr(tm)),2)+'.cgm'
	    file0 = file0(0)
	  endif
	  file = file0					; Remember file name.
	  dev = !d.name					; Remember plot device.
	  set_plot,'cgm'				; Turn cgm on.
	  device,file=file0				; Direct to file.
	  print,' CGM on.  Graphics redirected to cgm file '+file0
	  cgmflag = 1					; Set CGM flag to on.
	endif else begin
	  device, /close				; Close CGM file.
	  set_plot,dev					; Reset to old plot dev.
	  print,' CGM Off.  File '+file+' complete.'	; Verify.
	  cgmflag = 0					; Set CGM flag to off.
	endelse
 
	return
	end
